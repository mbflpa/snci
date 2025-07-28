<cfprocessingdirective pageencoding="utf-8">

<!--- Usar dados específicos do CFC --->
<cfset objDados = createObject("component", "cfc.DeficienciasControleDados")>
<cfset dadosMensagem = objDados.obterDadosMensagemCard(application.rsUsuarioParametros.Und_MCU)>

<cfset dadosMeses = dadosMensagem.meses>
<cfset nomeMesAtual = dadosMeses.nomeMesAtual>
<cfset nomeMesAnterior = dadosMeses.nomeMesAnterior>
<cfset mesAtualId = dadosMeses.mesAtualId>
<cfset mesAnteriorId = dadosMeses.mesAnteriorId>

<!--- Usar dados de eventos já processados --->
<cfset eventosAtual = dadosMensagem.eventosMensagem.eventosAtual>
<cfset eventosAnterior = dadosMensagem.eventosMensagem.eventosAnterior>

<!--- Calcular evolução dos eventos --->
<cfset mensagemCard = "Acompanhe o desempenho das deficiências de controle da sua unidade.">
<cfset iconeCard = "fas fa-shield-alt">
<cfset tipoCard = "info">
<cfset badgeTexto = "Monitoramento">

<!--- Calcular diferença e percentual --->
<cfif eventosAnterior GT 0>
    <cfset diferencaEventos = eventosAtual - eventosAnterior>
    <cfset percentualMudanca = round(abs(diferencaEventos) / eventosAnterior * 100)>
    
    <cfif eventosAtual LT eventosAnterior>
        <!--- Mês atual tem MENOS eventos que o anterior = EXCELENTE --->
        <cfset mensagemCard = "Excelente! Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle <span class='event-count'>#eventosAtual# evento(s)</span> reduziu #percentualMudanca#% em relação ao mês anterior <span class='event-count'>#eventosAnterior# evento(s)</span>.">
        <cfset iconeCard = "fas fa-check-circle">
        <cfset tipoCard = "success">
        <cfset badgeTexto = "Excelente">
    <cfelseif eventosAtual GT eventosAnterior>
        <!--- Mês atual tem MAIS eventos que o anterior = PREOCUPANTE --->
        <cfset mensagemCard = "Atenção! Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle <span class='event-count'>#eventosAtual# evento(s)</span> aumentou #percentualMudanca#% em relação ao mês anterior <span class='event-count'>#eventosAnterior# evento(s)</span>.">
        <cfset iconeCard = "fas fa-exclamation-triangle">
        <cfset tipoCard = "danger">
        <cfset badgeTexto = "Atenção">
    <cfelse>
        <!--- Mesmo número de eventos --->
        <cfif eventosAtual EQ 0>
            <cfset mensagemCard = "Perfeito! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle, mantendo o excelente resultado do mês anterior.">
            <cfset iconeCard = "fas fa-trophy">
            <cfset tipoCard = "info">
            <cfset badgeTexto = "Perfeito">
        <cfelse>
            <cfset mensagemCard = "Em #monthAsString(listLast(mesAtualId, "-"))#, o total de eventos com deficiências de controle <span class='event-count'>#eventosAtual# evento(s)</span> manteve-se estável em relação ao mês anterior <span class='event-count'>#eventosAnterior# evento(s)</span>.">
            <cfset iconeCard = "fas fa-equals">
            <cfset tipoCard = "info">
            <cfset badgeTexto = "Estável">
        </cfif>
    </cfif>
<cfelseif eventosAnterior EQ 0 AND eventosAtual GT 0>
    <!--- Não havia eventos no mês anterior e agora há = PIOROU --->
    <cfset mensagemCard = "Atenção! Em #monthAsString(listLast(mesAtualId, "-"))#, foram registrados <span class='event-count'>#eventosAtual# evento(s)</span> de deficiências de controle, e nenhum evento no mês anterior.">
    <cfset iconeCard = "fas fa-exclamation-triangle">
    <cfset tipoCard = "warning">
    <cfset badgeTexto = "Atenção">
<cfelseif eventosAnterior EQ 0 AND eventosAtual EQ 0>
    <!--- Não havia eventos e continua não havendo = EXCELENTE --->
    <cfset mensagemCard = "Perfeito! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle, mantendo o excelente resultado do mês anterior.">
    <cfset iconeCard = "fas fa-trophy">
    <cfset tipoCard = "info">
    <cfset badgeTexto = "Perfeito">
<cfelse>
    <!--- Primeiro mês com dados ou casos especiais --->
    <cfif eventosAtual EQ 0>
        <cfset mensagemCard = "Excelente! Em #monthAsString(listLast(mesAtualId, "-"))#, não foram registrados eventos de deficiências de controle.">
        <cfset iconeCard = "fas fa-check-circle">
        <cfset tipoCard = "success">
        <cfset badgeTexto = "Excelente">
    <cfelse>
        <cfset mensagemCard = "Em #monthAsString(listLast(mesAtualId, "-"))#, foram registrados <span class='event-count'>#eventosAtual# evento(s)</span> de deficiências de controle.">
        <cfset iconeCard = "fas fa-info-circle">
        <cfset tipoCard = "info">
        <cfset badgeTexto = "Informação">
    </cfif>
</cfif>

<cfparam name="attributes.titulo" default="Resultado Geral - Deficiências de Controle">
<cfparam name="attributes.mensagem" default="#mensagemCard#">
<cfparam name="attributes.icone" default="#iconeCard#">
<cfparam name="attributes.tipo" default="#tipoCard#">
<cfparam name="attributes.badge" default="#badgeTexto#">
<cfparam name="attributes.cssClass" default="">

<style>
    * {
        box-sizing: border-box;
    }

    /* Card Principal Otimizado */
    .status-card {
        position: relative;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 20px;
        padding: 0;
        box-shadow: 
            0 20px 40px rgba(102, 126, 234, 0.3),
            0 8px 32px rgba(118, 75, 162, 0.2);
        overflow: hidden;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        cursor: pointer;
        margin-bottom: 24px;
        margin-top: 80px;
    }

    .status-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 
            0 30px 60px rgba(102, 126, 234, 0.4),
            0 16px 48px rgba(118, 75, 162, 0.3);
    }

    /* Efeito de ondas de fundo */
    .status-card::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
        pointer-events: none;
    }

    .status-card::after {
        content: '';
        position: absolute;
        bottom: -20px;
        left: -20px;
        width: 120px;
        height: 120px;
        background: radial-gradient(circle, rgba(255, 255, 255, 0.08) 0%, transparent 70%);
        border-radius: 50%;
    }

    .card-content {
        position: relative;
        z-index: 2;
        padding: 32px;
        display: flex;
        align-items: center;
        gap: 24px;
    }

    /* Ícone com design melhorado */
    .status-icon {
        position: relative;
        width: 80px;
        height: 80px;
        background: linear-gradient(135deg, rgba(255, 255, 255, 0.2), rgba(255, 255, 255, 0.1));
        border-radius: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        box-shadow: 
            inset 0 1px 0 rgba(255, 255, 255, 0.3),
            0 8px 32px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
    }

    .status-icon:hover {
        transform: scale(1.1) rotate(5deg);
    }

    .status-icon i {
        font-size: 2.2rem;
        color: #ffd700;
        text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
    }

    /* Conteúdo do texto */
    .status-content {
        flex: 1;
        min-width: 0;
    }

    .status-title {
        font-size: 1.8rem;
        font-weight: 800;
        color: #ffffff;
        margin-bottom: 12px;
        text-shadow: 0 2px 16px rgba(0, 0, 0, 0.3);
        letter-spacing: 0.5px;
        line-height: 1.2;
    }

    .status-message {
        font-size: 1.1rem;
        font-weight: 400;
        color: rgba(255, 255, 255, 0.95);
        line-height: 1.6;
        text-shadow: 0 1px 8px rgba(0, 0, 0, 0.2);
    }

    .event-count {
        display: inline-flex;
        align-items: center;
        background: rgba(255, 255, 255, 0.2);
        color: #ffd700;
        padding: 4px 12px;
        border-radius: 20px;
        font-weight: 700;
        font-size: 0.95rem;
        margin: 0 4px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    /* Badge de status no canto */
    .status-badge {
        position: absolute;
        top: 20px;
        right: 20px;
        background: rgba(255, 255, 255, 0.9);
        color: #667eea;
        padding: 6px 16px;
        border-radius: 50px;
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    /* Variações de cor baseadas no tipo */
    .status-card.success {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        box-shadow: 
            0 20px 40px rgba(16, 185, 129, 0.3),
            0 8px 32px rgba(5, 150, 105, 0.2);
    }

    .status-card.warning {
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        box-shadow: 
            0 20px 40px rgba(245, 158, 11, 0.3),
            0 8px 32px rgba(217, 119, 6, 0.2);
    }

    .status-card.danger {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        box-shadow: 
            0 20px 40px rgba(239, 68, 68, 0.3),
            0 8px 32px rgba(220, 38, 38, 0.2);
    }

    .status-card.info {
        background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        box-shadow: 
            0 20px 40px rgba(59, 130, 246, 0.3),
            0 8px 32px rgba(29, 78, 216, 0.2);
    }

    /* Responsividade melhorada */
    @media (max-width: 768px) {
        .card-content {
            flex-direction: column;
            align-items: flex-start;
            padding: 24px 20px;
            gap: 16px;
        }

        .status-icon {
            width: 60px;
            height: 60px;
            align-self: center;
        }

        .status-icon i {
            font-size: 1.8rem;
        }

        .status-title {
            font-size: 1.4rem;
            text-align: center;
            align-self: stretch;
        }

        .status-message {
            font-size: 1rem;
            text-align: center;
        }

        .status-badge {
            top: 12px;
            right: 12px;
            font-size: 0.7rem;
            padding: 4px 12px;
        }

        .event-count {
            font-size: 0.9rem;
            padding: 3px 10px;
        }
    }

    /* Micro-interações */
    .status-card:active {
        transform: translateY(-4px) scale(1.01);
    }
</style>

<div class="status-card <cfoutput>#attributes.tipo# #attributes.cssClass#</cfoutput>">
    <div class="status-badge"><cfoutput>#attributes.badge#</cfoutput></div>
    <div class="card-content">
        <div class="status-icon">
            <i class="<cfoutput>#attributes.icone#</cfoutput>"></i>
        </div>
        <div class="status-content">
            <div class="status-title"><cfoutput>#attributes.titulo#</cfoutput></div>
            <div class="status-message"><cfoutput>#attributes.mensagem#</cfoutput></div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Efeitos de hover melhorados
        const cards = $('.status-card');
        
        cards.on('mouseenter', function() {
            $(this).css('transform', 'translateY(-8px) scale(1.02)');
        });
        
        cards.on('mouseleave', function() {
            $(this).css('transform', 'translateY(0) scale(1)');
        });

        cards.on('click', function() {
            const $this = $(this);
            $this.css('transform', 'translateY(-4px) scale(1.01)');
            setTimeout(() => {
                $this.css('transform', 'translateY(-8px) scale(1.02)');
            }, 150);
        });
    });
</script>
