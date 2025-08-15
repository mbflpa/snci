<cfprocessingdirective pageencoding = "utf-8">
<cfcontent type="text/html">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">
<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>SNCI - Deficiências do Controle</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png" />
   
   
    <style>
        .deficiencias-geral-layout {
            padding: 16px;

        }
        
        /* Força alinhamento específico dos containers na página index */
        .deficiencias-geral-layout .dashboard-main-content,
        .deficiencias-geral-layout .dashboard-kpi-panel {
            margin: 0 !important;
            padding: 0 !important;
        }
        
        /* Força os componentes dentro do layout a alinharem no topo */
        .deficiencias-geral-layout .dashboard-main-content > .snci-desempenho-assunto,
        .deficiencias-geral-layout .dashboard-kpi-panel > .snci-resumo-geral {
            margin-top: 0 !important;
            padding-top: 0 !important;
        }
        
        /* Força containers internos dos componentes a alinharem */
        .deficiencias-geral-layout .snci-desempenho-assunto .desempenho-container,
        .deficiencias-geral-layout .snci-resumo-geral .desempenho-container {
            margin-top: 0 !important;
            padding-top: 0 !important;
        }
        
        /* Força os comparison-container de ambos componentes */
        .deficiencias-geral-layout .snci-desempenho-assunto .comparison-container,
        .deficiencias-geral-layout .snci-resumo-geral .comparison-container {
            margin-top: 0 !important;
            padding-top: 12px !important;
        }
        
        /* Força títulos h2 de ambos componentes para alinhamento perfeito */
        .deficiencias-geral-layout .snci-desempenho-assunto .comparison-container h2,
        .deficiencias-geral-layout .snci-resumo-geral .comparison-container h2 {
            margin-top: 0 !important;
            padding-top: 0 !important;
            line-height: 1.25rem;
        }

        .dashboard-main-content {
            flex: none; /* Remove flex shorthand for testing */
        }

        .dashboard-kpi-panel {
            flex: none; /* Remove flex shorthand for testing */
          }

        /* Responsividade */
        @media (max-width: 1200px) {
            .deficiencias-geral-layout {
                flex-direction: column;
            }
        }

        /*=== TOUR SHEPHERD.JS - DESIGN MODERNO E ATRAENTE ===*/
        
        /* Animações personalizadas */
        @keyframes tourFadeInUp {
            from {
                opacity: 0;
                transform: translate3d(0, 40px, 0) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translate3d(0, 0, 0) scale(1);
            }
        }

        @keyframes tourPulse {
            0%, 100% {
                transform: scale(1);
                box-shadow: 0 10px 40px rgba(0, 65, 107, 0.2);
            }
            50% {
                transform: scale(1.02);
                box-shadow: 0 15px 50px rgba(0, 65, 107, 0.3);
            }
        }

        @keyframes tourShine {
            0% {
                background-position: -200% center;
            }
            100% {
                background-position: 200% center;
            }
        }

        @keyframes tourGlow {
            0%, 100% {
                box-shadow: 0 0 20px rgba(255, 196, 14, 0.4);
            }
            50% {
                box-shadow: 0 0 30px rgba(255, 196, 14, 0.7);
            }
        }

        /* Container principal do modal */
        .shepherd-modal-overlay-container {
            background: rgba(0, 0, 0, 0.75) !important;
            backdrop-filter: blur(8px) !important;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1) !important;
        }

        /* Elemento principal do tour */
        .shepherd-element {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif !important;
            background: linear-gradient(145deg, #ffffff, #f8f9fa) !important;
            background-image: 
                linear-gradient(145deg, #ffffff, #f8f9fa),
                linear-gradient(145deg, #00416B, #0083CA) !important;
            background-origin: border-box !important;
            background-clip: content-box, border-box !important;
            border-radius: 20px !important;
            box-shadow: 
                0 20px 60px rgba(0, 65, 107, 0.2),
                0 10px 30px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.5) !important;
            max-width: 420px !important;
            min-height: 200px !important;
            opacity: 0 !important;
            transform: none !important;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: absolute !important;
            overflow: hidden !important;
        }

        /* Efeito de brilho sutil no fundo */
        .shepherd-element::before {
            content: '' !important;
            position: absolute !important;
            top: 0 !important;
            left: -100% !important;
            width: 100% !important;
            height: 100% !important;
            background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.1),
                transparent
            ) !important;
            transition: left 0.6s ease !important;
        }

        .shepherd-element:hover::before {
            left: 100% !important;
        }

        /* Estado ativo do elemento */
        .shepherd-element.shepherd-enabled {
            opacity: 1 !important;
            transform: scale(1) translateY(0) !important;
            animation: tourFadeInUp 0.5s ease-out, tourPulse 2s ease-in-out infinite 2s !important;
        }

        /* Cabeçalho com gradiente dinâmico */
        .shepherd-header {
            background: linear-gradient(135deg, #00416B 0%, #0083CA 50%, #00B4D8 100%) !important;
            background-size: 200% 200% !important;
            animation: tourShine 3s linear infinite !important;
            color: #fff !important;
            padding: 1rem 1.5rem !important;
            border-top-left-radius: 18px !important;
            border-top-right-radius: 18px !important;
            position: relative !important;
            overflow: hidden !important;
        }

        /* Efeito de ondas no header */
        .shepherd-header::before {
            content: '' !important;
            position: absolute !important;
            top: -50% !important;
            left: -50% !important;
            width: 200% !important;
            height: 200% !important;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%) !important;
            animation: tourPulse 4s ease-in-out infinite !important;
            pointer-events: none !important;
        }

        /* Título com efeito especial */
        .shepherd-title {
            font-weight: 700 !important;
            font-size: 1.1rem !important;
            color: #fff !important;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
            position: relative !important;
            z-index: 2 !important;
            letter-spacing: 0.5px !important;
        }

        /* Conteúdo do texto */
        .shepherd-text {
            padding: 1.5rem !important;
            color: #2c3e50 !important;
            font-size: 0.95rem !important;
            line-height: 1.7 !important;
            text-align: justify !important;
            position: relative !important;
            background: linear-gradient(145deg, #ffffff, #f8f9fa) !important;
        }

      

        /* Rodapé moderno */
        .shepherd-footer {
            background: linear-gradient(145deg, #f8f9fa, #e9ecef) !important;
            border-top: 1px solid rgba(0, 65, 107, 0.1) !important;
            padding: 0.3rem 1rem !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            border-bottom-left-radius: 18px !important;
            border-bottom-right-radius: 18px !important;
        }

        /* Botões com design premium */
        .shepherd-button {
            background: linear-gradient(135deg, #FFC20E 0%, #FFD400 100%) !important;
            color: #00416B !important;
            border: none !important;
            border-radius: 25px !important;
            padding:0.5rem !important;
            font-weight: 700 !important;
            font-size: 0.7rem !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            cursor: pointer !important;
            position: relative !important;
            overflow: hidden !important;
            box-shadow: 0 4px 15px rgba(255, 196, 14, 0.3) !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
        }

        /* Efeito de hover nos botões */
        .shepherd-button:hover {
            background: linear-gradient(135deg, #FFD400 0%, #FFC20E 100%) !important;
            transform: translateY(-3px) scale(1.05) !important;
            box-shadow: 0 8px 25px rgba(255, 196, 14, 0.5) !important;
            animation: tourGlow 1.5s ease-in-out infinite !important;
        }

        /* Efeito de clique */
        .shepherd-button:active {
            transform: translateY(-1px) scale(1.02) !important;
            box-shadow: 0 4px 15px rgba(255, 196, 14, 0.4) !important;
        }

        /* Botão secundário */
        .shepherd-button.shepherd-button-secondary {
            background: linear-gradient(135deg, #e9ecef 0%, #f8f9fa 100%) !important;
            color: #495057 !important;
            border: 2px solid #dee2e6 !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1) !important;
        }

        .shepherd-button.shepherd-button-secondary:hover {
            background: linear-gradient(135deg, #dee2e6 0%, #e9ecef 100%) !important;
            color: #212529 !important;
            border-color: #ced4da !important;
            transform: translateY(-2px) scale(1.03) !important;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15) !important;
        }

        /* Ícone de fechar personalizado */
        .shepherd-cancel-icon {
            color: #fff !important;
            opacity: 0.8 !important;
            font-size: 1.2rem !important;
            transition: all 0.3s ease !important;
            cursor: pointer !important;
        }

        .shepherd-cancel-icon:hover {
            opacity: 1 !important;
            transform: rotate(90deg) scale(1.1) !important;
            color: #FFD400 !important;
        }

        /* Seta do tooltip com gradiente */
        .shepherd-element[data-popper-placement^="bottom"] > .shepherd-arrow::before {
            border-bottom-color: #00416B !important;
        }

        .shepherd-element[data-popper-placement^="top"] > .shepherd-arrow::before {
            border-top-color: #00416B !important;
        }

        .shepherd-element[data-popper-placement^="left"] > .shepherd-arrow::before {
            border-left-color: #00416B !important;
        }

        .shepherd-element[data-popper-placement^="right"] > .shepherd-arrow::before {
            border-right-color: #00416B !important;
        }

        /* Efeitos especiais para elementos destacados */
        .shepherd-target {
            position: relative !important;
            z-index: 9999 !important;
        }

        /* Pulse effect para elementos em destaque */
        .shepherd-target::before {
            content: '' !important;
            position: absolute !important;
            top: -10px !important;
            left: -10px !important;
            right: -10px !important;
            bottom: -10px !important;
            border: 3px solid #FFC20E !important;
            border-radius: 10px !important;
            animation: tourPulse 2s ease-in-out infinite !important;
            pointer-events: none !important;
            z-index: -1 !important;
        }

        /* Responsividade para dispositivos móveis */
        @media (max-width: 768px) {
            .shepherd-element {
                max-width: 95vw !important;
                margin: 0 10px !important;
                border-radius: 15px !important;
            }

            .shepherd-header {
                padding: 0.8rem 1rem !important;
                border-radius: 13px 13px 0 0 !important;
            }

            .shepherd-title {
                font-size: 1rem !important;
            }

            .shepherd-text {
                padding: 1rem !important;
                font-size: 0.9rem !important;
            }

            .shepherd-footer {
                padding: 0.8rem 1rem !important;
                border-radius: 0 0 13px 13px !important;
                flex-direction: column !important;
                gap: 0.5rem !important;
            }

            .shepherd-button {
                width: 100% !important;
                margin: 0.2rem 0 !important;
            }
        }

        /* Melhorar contraste para acessibilidade */
        @media (prefers-contrast: high) {
            .shepherd-element {
                border-width: 3px !important;
            }

            .shepherd-text {
                color: #000 !important;
            }

            .shepherd-button {
                border: 2px solid #00416B !important;
            }
        }

        /* Suporte para modo escuro */
        @media (prefers-color-scheme: dark) {
            .shepherd-element {
                background: linear-gradient(145deg, #2c3e50, #34495e) !important;
                color: #ecf0f1 !important;
            }

            .shepherd-text {
                background: linear-gradient(145deg, #2c3e50, #34495e) !important;
                color: #ecf0f1 !important;
            }

            .shepherd-footer {
                background: linear-gradient(145deg, #34495e, #2c3e50) !important;
            }
        }

        /* Animação de entrada para botão de iniciar tour */
        #startTourBtn {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
        }

        #startTourBtn:hover {
            transform: translateY(-2px) !important;
            box-shadow: 0 8px 25px rgba(0, 123, 255, 0.3) !important;
        }

        #startTourBtn::before {
            content: '' !important;
            position: absolute !important;
            top: 0 !important;
            left: -100% !important;
            width: 100% !important;
            height: 100% !important;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent) !important;
            transition: left 0.5s !important;
        }

        #startTourBtn:hover::before {
            left: 100% !important;
        }

        /* Afasta o tooltip do alvo quando está embaixo */
        .shepherd-element[data-popper-placement^="bottom"] {
            margin-top: 22px !important; /* ajuste conforme necessário */
        }
        /* Afasta o tooltip do alvo quando está em cima */
        .shepherd-element[data-popper-placement^="top"] {
            margin-bottom: 22px !important;
        }
        /* Afasta o tooltip do alvo quando está à esquerda */
        .shepherd-element[data-popper-placement^="left"] {
            margin-right: 22px !important;
        }
        /* Afasta o tooltip do alvo quando está à direita */
        .shepherd-element[data-popper-placement^="right"] {
            margin-left: 22px !important;
        }

    </style>
</head>

<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">
 
        <cfinclude template="includes/aa_sidebar.cfm">
        <cfinclude template="includes/aa_navBar.cfm">
        <div class="content-wrapper">
            <section class="content">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-12">
                            <h3 class="tituloPagina m-3 " style="padding-bottom: 0!important;margin-bottom: 0!important;">Avaliação Geral - Deficiência do Controle
                                <i class="fa-regular fa-circle-question info-icon-automatizadas" style="position: relative;right: 3px;bottom: 13px;font-size: 1rem;" 
                                    data-toggle="popover" 
                                    data-trigger="hover" 
                                    data-placement="right"
                                    data-html="true"
                                    data-content="Tratam-se de situações identificadas nas avaliações realizadas nas unidades operacionais, por meio da aplicação de testes de controle (Plano de Testes), que não condizem com o previsto em normas internas dos Correios, documentos de orientações vigentes (ofícios) e legislações.">
                                </i>
                                <button id="startTourBtn" class="btn btn-sm btn-outline-primary ml-3" style="font-size: 0.8rem; vertical-align: middle;">
                                    <i class="fas fa-route"></i> Iniciar Tour
                                </button>
                            </h3>
                        </div>
                    </div>
                </div>
 
                <div class="deficiencias-geral-layout">
                    <div class="dashboard-kpi-panel">
                        <cfinclude template="includes/componentes_deficiencias_controle/def_controle_resumo_geral.cfm">
                    </div>
                    <div class="dashboard-main-content">
                        <cfinclude template="includes/componentes_deficiencias_controle/def_controle_desempenho_assunto.cfm">
                    </div>
                    
                </div>
            </section>
        </div>

        <cfinclude template="includes/aa_footer.cfm">
   </div>
    
   
    <script language="JavaScript">
        $(document).ready(function(){
            $.widget.bridge('uibutton', $.ui.button);
            $('#modalOverlay').modal('hide');
            // Inicializa todos os popovers
				$('[data-toggle="popover"]').popover({
					html: true,
					trigger: 'hover'
				});
				
				// Popover com dismiss específico
				$('.popover-dismiss').popover({
					trigger: 'hover'
				});
        });
   
        $(window).on('load', function() {
            const tour = new Shepherd.Tour({
                useModalOverlay: true,
                defaultStepOptions: {
                    classes: 'shadow-md bg-purple-dark',
                    scrollTo: { behavior: 'smooth', block: 'center' },
                    cancelIcon: {
                        enabled: true
                    }
                }
            });

            tour.addStep({
                title: 'Bem-vindo!',
                text: 'Este tour irá guiá-lo pelas principais funcionalidades desta página. Vamos começar?',
                attachTo: {
                    element: '#startTourBtn',
                    on: 'bottom'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() {
                            return this.next();
                        },
                        text: 'Iniciar'
                    }
                ]
            });

            // tour.addStep({
            //     title: 'Menu de Navegação',
            //     text: 'Use este menu para navegar entre as diferentes seções das Avaliações Automatizadas.',
            //     attachTo: {
            //         element: '.main-sidebar',
            //         on: 'right'
            //     },
            //     buttons: [
            //         {
            //             action() { return this.back(); },
            //             classes: 'shepherd-button-secondary',
            //             text: 'Voltar'
            //         },
            //         {
            //             action() { return this.next(); },
            //             text: 'Avançar'
            //         }
            //     ]
            // });

            // tour.addStep({
            //     title: 'Filtro de Mês',
            //     text: 'Selecione um mês para visualizar os dados do período correspondente. A página será atualizada automaticamente.',
            //     attachTo: {
            //         element: '.meses-container',
            //         on: 'bottom'
            //     },
            //     buttons: [
            //         {
            //             action() { return this.back(); },
            //             classes: 'shepherd-button-secondary',
            //             text: 'Voltar'
            //         },
            //         {
            //             action() { return this.next(); },
            //             text: 'Avançar'
            //         }
            //     ]
            // });

            tour.addStep({
                title: 'Resumo Geral',
                text: 'Nesta seção, você encontrará os resultados acumulados de janeiro até o mês que você escolher no filtro "Mês".',
                attachTo: {
                    element: '.snci-resumo-geral',
                    on: 'bottom'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });

            tour.addStep({
                title: 'Métrica',
                text: 'Cada quadro mostra um tipo de informação. Se você passar o mouse sobre o ícone de interrogação  <strong><i class="fa-regular fa-circle-question"></i></strong> , verá uma explicação detalhada.<br>Esse ícone funciona da mesma forma em toda a página: sempre que você o encontrar, pode usá-lo para ver mais informações.',
                attachTo: {
                    element: '.kpi-card:first-child',
                    on: 'bottom'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });

            tour.addStep({
                title: 'Desempenho por Assunto',
                text: 'Navegue por esta seção para ver o desempenho dos testes, assunto por assunto. Você pode comparar facilmente a quantidade de eventos do mês atual com a do mês anterior.',
                attachTo: {
                    element: '.snci-desempenho-assunto',
                    on: 'top'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });
            
            tour.addStep({
                title: 'Navegação dos Assuntos',
                text: 'Use as setas para navegar entre os diferentes assuntos ou use a barra de rolagem na parte inferior desta seção.',
                attachTo: {
                    element: '.carousel-controls',
                    on: 'top'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });


            tour.addStep({
                title: 'Visualizar Evidências',
                text: 'Este ícone <i class="fa-solid fa-eye"></i> aparecerá no canto superior direito do cartão do último mês avaliado, sempre que as evidências estiverem disponíveis. Com um clique sobre a quantidade de eventos, é possível visualizar as evidências de forma detalhada. <br><span style="color: red;">Obs.: As evidências só estarão disponíveis para o último mês avaliado.</span>',
                attachTo: {
                    element: '.current',
                    on: 'top-end'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });


                      
            tour.addStep({
                title: 'Assunto reincidente',
                text: 'Quando o Assunto for reincidente, a indicação aparecerá no cartão correspondente. Assuntos reincidentes são aqueles com, pelo menos, um evento aparecendo no mês atual e também no mês anterior.',
                attachTo: {
                    element: '.badge-reincidente',
                    on: 'right'
                },
                beforeShowPromise: function() {
                    return new Promise(function(resolve) {
                        // Se não existe nenhum .badge-reincidente, insere temporariamente
                        if ($('.badge-reincidente').length === 0) {
                            var $card = $('.period-card.current').first();
                            if ($card.length) {
                                var $eventos = $card.find('.eventos-container');
                                if ($eventos.length) {
                                    $eventos.append('<span class="badge-reincidente tour-temp">Reincidente</span>');
                                }
                            }
                        }
                        resolve();
                    });
                },
                when: {
                    hide: function() {
                        // Remove o badge temporário após o passo do tour
                        $('.badge-reincidente.tour-temp').remove();
                    }
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });
            
                        // ...existing code...
            tour.addStep({
                title: 'Valor Envolvido',
                text: 'Sempre que eventos apresentarem valores envolvidos, o total do mês será exibido no cartão correspondente.',
                attachTo: {
                    element: '.valor-envolvido',
                    on: 'right'
                },
                beforeShowPromise: function() {
                    return new Promise(function(resolve) {
                        // Se não existe nenhum .valor-envolvido, insere temporariamente
                        if ($('.valor-envolvido').length === 0) {
                            var $card = $('.period-card.current').first();
                            if ($card.length) {
                                var $eventos = $card.find('.eventos-container');
                                if ($eventos.length) {
                                    $eventos.append('<span class="valor-envolvido tour-temp">R$0,00</span>');
                                }
                            }
                        }
                        resolve();
                    });
                },
                when: {
                    hide: function() {
                        // Remove o valor temporário após o passo do tour
                        $('.valor-envolvido.tour-temp').remove();
                    }
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });
            // ...existing code...

            tour.addStep({
                title: 'Informações sobre o Assunto',
                text: 'Recomenda-se especial atenção às informações apresentadas neste ícone <strong><i class="fa-regular fa-circle-question"></i></strong>. Ele mostra detalhes importantes sobre cada assunto.',
                attachTo: {
                    element: '.card-title',
                    on: 'right'
                },
                buttons: [
                    {
                        action() { return this.cancel(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Fechar'
                    },
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Avançar'
                    }
                ]
            });

            tour.addStep({
                title: 'Fim do tour',
                text: 'Chegamos ao final desse tour. Sempre que desejar, você pode reiniciá-lo clicando no botão "Iniciar Tour".',
                attachTo: {
                    element: '#startTourBtn',
                    on: 'right'
                },
                buttons: [
                    
                    {
                        action() { return this.back(); },
                        classes: 'shepherd-button-secondary',
                        text: 'Voltar'
                    },
                    {
                        action() { return this.next(); },
                        text: 'Finalizar'
                    }
                ]
            });


            if (!localStorage.getItem('tourVisto')) {
                tour.start();
            }

            const onEndTour = () => localStorage.setItem('tourVisto', 'true');
            tour.on('complete', onEndTour);
            tour.on('cancel', onEndTour);

            $('#startTourBtn').on('click', function() {
                tour.start();
            });
        });
    </script>
</body>

</html>