<cfprocessingdirective pageencoding="utf-8">

<cfparam name="attributes.titulo" default="Painel de Deficiências de Controle">
<cfparam name="attributes.mensagem" default="Acompanhe o desempenho das deficiências de controle da sua unidade.">
<cfparam name="attributes.icone" default="fas fa-shield-alt">
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
