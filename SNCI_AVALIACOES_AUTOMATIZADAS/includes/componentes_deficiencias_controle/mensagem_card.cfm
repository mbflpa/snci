<cfprocessingdirective pageencoding="utf-8">


<!-- Inicializa nomes dos meses para evitar erro de variável indefinida -->
<cfset nomeMesAtual = "Mês Atual">
<cfset nomeMesAnterior = "Mês Anterior">
<!--- Consulta para obter os dois últimos meses disponíveis na tabela --->
<cfquery name="rsUltimosMeses" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
    FROM fato_verificacao
    WHERE data_encerramento IS NOT NULL
    GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
    ORDER BY mes_ano DESC
</cfquery>

<cfif rsUltimosMeses.recordCount GTE 2>
    <cfset mesAtualId = rsUltimosMeses.mes_ano[1]>
    <cfset mesAnteriorId = rsUltimosMeses.mes_ano[2]>
    <cfset nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
    <cfset nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
<cfelse>
    <cfset mesAtualId = "">
    <cfset mesAnteriorId = "">
</cfif>

<!--- Consulta agregada por mês para calcular evolução --->
<cfquery name="rsDadosAssuntoMensagem" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT 
        FORMAT(f.data_encerramento, 'yyyy-MM') AS mes_ano,
        SUM(f.NC_Eventos) AS total_eventos
    FROM fato_verificacao f
    INNER JOIN dim_teste_processos p ON f.sk_grupo_item = p.sk_grupo_item
    WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rsUsuarioParametros.Und_MCU#">
      AND f.suspenso = 0
      AND f.sk_grupo_item <> 12
      AND FORMAT(f.data_encerramento, 'yyyy-MM') IN (
        <cfqueryparam value="#mesAtualId#,#mesAnteriorId#" list="true" cfsqltype="cf_sql_varchar">
      )
    GROUP BY FORMAT(f.data_encerramento, 'yyyy-MM')
    ORDER BY mes_ano DESC
</cfquery>

<!--- Calcular evolução dos eventos --->
<cfset eventosAtual = 0>
<cfset eventosAnterior = 0>
<cfset mensagemCard = "Acompanhe o desempenho das deficiências de controle da sua unidade.">
<cfset iconeCard = "fas fa-shield-alt">

<cfif rsDadosAssuntoMensagem.recordCount GT 0>
    <cfloop query="rsDadosAssuntoMensagem">
        <cfif mes_ano EQ mesAtualId>
            <cfset eventosAtual = total_eventos>
        <cfelseif mes_ano EQ mesAnteriorId>
            <cfset eventosAnterior = total_eventos>
        </cfif>
    </cfloop>
    
    <!--- Calcular diferença e percentual --->
    <cfif eventosAnterior GT 0>
        <cfset diferencaEventos = eventosAtual - eventosAnterior>
        <cfset percentualMudanca = round(abs(diferencaEventos) / eventosAnterior * 100)>
        
        <cfif eventosAtual LT eventosAnterior>
            <!--- Mês atual tem MENOS eventos que o anterior = EXCELENTE (menos eventos de deficiência = melhor) --->
            <cfset mensagemCard = "Excelente! Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle ( <span class='qEventos'>#eventosAtual# evento(s)</span> ) reduziu #percentualMudanca#% em relação ao mês anterior ( <span class='qEventos'>#eventosAnterior# evento(s)</span> ).">
            <cfset iconeCard = "fas fa-check-circle">
        <cfelseif eventosAtual GT eventosAnterior>
            <!--- Mês atual tem MAIS eventos que o anterior = PREOCUPANTE (mais eventos de deficiência = pior) --->
            <cfset mensagemCard = "Atenção! Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle ( <span class='qEventos'>#eventosAtual# evento(s)</span> ) aumentou #percentualMudanca#% em relação ao mês anterior ( <span class='qEventos'>#eventosAnterior# evento(s)</span> ).">
            <cfset iconeCard = "fas fa-exclamation-triangle">
        <cfelse>
            <!--- Mesmo número de eventos --->
            <cfif eventosAtual EQ 0>
                <cfset mensagemCard = "Perfeito! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle, mantendo o excelente resultado do mês anterior.">
                <cfset iconeCard = "fas fa-trophy">
            <cfelse>
                <cfset mensagemCard = "Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle ( <span class='qEventos'>#eventosAtual# evento(s)</span> ) manteve-se estável em relação ao mês anterior ( <span class='qEventos'>#eventosAnterior# evento(s)</span> ).">
                <cfset iconeCard = "fas fa-equals">
            </cfif>
        </cfif>
    <cfelseif eventosAnterior EQ 0 AND eventosAtual GT 0>
        <!--- Não havia eventos no mês anterior e agora há = PIOROU --->
        <cfset mensagemCard = "Atenção! Em #monthAsString(listLast(mesAtualId, "-"))#, foram registrados #eventosAtual# evento(s) de deficiências de controle ( <span class='qEventos'>#eventosAtual# evento(s)</span> ), comparado a nenhum evento no mês anterior.">
        <cfset iconeCard = "fas fa-exclamation-triangle">
    <cfelseif eventosAnterior EQ 0 AND eventosAtual EQ 0>
        <!--- Não havia eventos e continua não havendo = EXCELENTE --->
        <cfset mensagemCard = "Perfeito! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle, mantendo o excelente resultado do mês anterior.">
        <cfset iconeCard = "fas fa-trophy">
    <cfelse>
        <!--- Primeiro mês com dados ou casos especiais --->
        <cfif eventosAtual EQ 0>
            <cfset mensagemCard = "Excelente! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle.">
            <cfset iconeCard = "fas fa-check-circle">
        <cfelse>
            <cfset mensagemCard = "Em #monthAsString(listLast(mesAtualId, "-"))#, foram registrados #eventosAtual# evento(s) de deficiências de controle.">
            <cfset iconeCard = "fas fa-info-circle">
        </cfif>
    </cfif>
<cfelse>
    <!--- Sem dados disponíveis --->
    <cfset mensagemCard = "Não há dados de eventos disponíveis para os períodos consultados.">
    <cfset iconeCard = "fas fa-chart-line">
</cfif>

<cfparam name="attributes.titulo" default="Resultado Geral - Deficiências de Controle">
<cfparam name="attributes.mensagem" default="#mensagemCard#">
<cfparam name="attributes.icone" default="#iconeCard#">

<cfparam name="attributes.cssClass" default="">
<cfparam name="attributes.showAnimation" default="true">

<style>
    .mensagem-card-snci {
        width: 100%;
        background: linear-gradient(135deg, var(--azul_claro_correios, #a8dadc) 0%, var(--azul_correios, #003366) 100%);
        color: #fff;
        border-radius: var(--border-radius, 16px);
        box-shadow: var(--shadow, 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05));
        padding: 28px 32px 24px 32px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 24px;
        position: relative;
        overflow: hidden;
        transition: box-shadow 0.3s, transform 0.3s;
    }
    .mensagem-card-snci:hover {
        box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.10), 0 10px 10px -5px rgb(0 0 0 / 0.04);
        transform: translateY(-2px);
    }
    .mensagem-card-snci .mensagem-icon {
        font-size: 3rem;
        background: rgba(255,255,255,0.12);
        border-radius: 16px;
        padding: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        color: var(--secondary-color, #FFD200);
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    .mensagem-card-snci .mensagem-content {
        flex: 1;
        min-width: 0;
    }
    .mensagem-card-snci .mensagem-title {
        font-size: 1.6rem;
        font-weight: 700;
        margin-bottom: 8px;
        color: #fff;
        text-shadow: 0 2px 8px rgba(0,0,0,0.08);
        letter-spacing: 0.5px;
    }
    .mensagem-card-snci .mensagem-message {
        font-size: 1.1rem;
        font-weight: 400;
        color: #f1faee;
        opacity: 0.95;
        line-height: 1.5;
    }
    /* Animação */
    .mensagem-card-snci.fade-in-up {
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.6s cubic-bezier(.4,0,.2,1);
    }
    .mensagem-card-snci.fade-in-up.animate {
        opacity: 1;
        transform: translateY(0);
    }
    @media (max-width: 900px) {
        .mensagem-card-snci {
            flex-direction: column;
            align-items: flex-start;
            padding: 20px 12px 16px 12px;
            gap: 12px;
        }
        .mensagem-card-snci .mensagem-icon {
            font-size: 2.2rem;
            padding: 10px;
        }
        .mensagem-card-snci .mensagem-title {
            font-size: 1.2rem;
        }
        .mensagem-card-snci .mensagem-message {
            font-size: 1rem;
        }
    }
    .qEventos{
        font-weight: bold;
    }
</style>

<div class="mensagem-card-snci <cfif attributes.showAnimation eq 'true'>fade-in-up</cfif> <cfoutput>#attributes.cssClass#</cfoutput>" data-delay="50">
    <div class="mensagem-icon">
        <i class="<cfoutput>#attributes.icone#</cfoutput>"></i>
    </div>
    <div class="mensagem-content">
        <div class="mensagem-title"><cfoutput>#attributes.titulo#</cfoutput></div>
        <div class="mensagem-message"><cfoutput>#attributes.mensagem#</cfoutput></div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Animação de entrada
        <cfif attributes.showAnimation eq 'true'>
        setTimeout(function() {
            $('.mensagem-card-snci.fade-in-up').addClass('animate');
        }, $('.mensagem-card-snci').data('delay') || 50);
        <cfelse>
        $('.mensagem-card-snci.fade-in-up').addClass('animate');
        </cfif>
    });
</script>
