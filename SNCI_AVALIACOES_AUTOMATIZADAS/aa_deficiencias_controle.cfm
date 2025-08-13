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

        /* Modern and fluid Shepherd.js styles using Correios color palette */
        .shepherd-element {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: #fff;
            border-radius: 8px;
            border: 1px solid var(--azul_correios, #00416B);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            max-width: 380px;
            opacity: 0;
            transform: scale(0.95) translateY(10px);
            transition: opacity 0.3s ease-in-out, transform 0.3s ease-in-out;
        }

        .shepherd-element.shepherd-enabled {
            opacity: 1;
            transform: scale(1) translateY(0);
        }

        .shepherd-header {
            background: linear-gradient(135deg, var(--azul_correios, #00416B), var(--azul_claro_correios, #0083CA));
            color: #fff;
            padding: 0.75rem 1rem;
            border-top-left-radius: 7px;
            border-top-right-radius: 7px;
        }

        .shepherd-title {
            font-weight: 600;
            font-size: 1rem;
        }

        .shepherd-text {
            padding: 1rem;
            color: #495057;
            font-size: 0.9rem;
            line-height: 1.6;
        }

        .shepherd-footer {
            border-top: 1px solid #dee2e6;
            padding: 0.75rem 1rem;
        }

        .shepherd-button {
            background: var(--amarelo_prisma_escuro_correios, #FFC20E);
            color: var(--azul_correios, #00416B);
            border: none;
            border-radius: 5px;
            padding: 0.5rem 1rem;
            font-weight: bold;
            transform: translateY(0);
            transition: all 0.2s ease;
        }

        .shepherd-button:hover {
            background: var(--amarelo_correios, #FFD400);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .shepherd-button.shepherd-button-secondary {
            background: #e9ecef;
            color: #495057;
        }

        .shepherd-button.shepherd-button-secondary:hover {
            background: #ced4da;
        }

        .shepherd-cancel-icon {
            color: #fff;
            opacity: 0.8;
        }
        .shepherd-cancel-icon:hover {
            opacity: 1;
        }

        .shepherd-arrow::before {
            background-color: var(--azul_correios, #00416B);
        }

        .shepherd-arrow::after {
            content: '';
            position: absolute;
            top: 1px;
            left: 1px;
            width: 14px;
            height: 14px;
            background: #fff;
            transform: rotate(45deg);
            z-index: 1;
            border-right: 1px solid var(--azul_correios, #00416B);
            border-bottom: 1px solid var(--azul_correios, #00416B);
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
                            <h3 class="m-3" style="padding-bottom: 0!important;margin-bottom: 0!important;">Avaliação Geral - Deficiência do Controle
                                <i class="fas fa-info-circle info-icon-automatizadas" style="position: relative;right: 3px;bottom: 13px;font-size: 1rem;" 
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
    </script>

    <script>
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
            title: 'Bem-vindo ao Tour!',
            text: 'Este tour irá guiá-lo pelas principais funcionalidades desta página. Vamos começar?',
            buttons: [
                {
                    action() {
                        return this.next();
                    },
                    text: 'Iniciar'
                }
            ]
        });

        tour.addStep({
            title: 'Menu de Navegação',
            text: 'Use este menu para navegar entre as diferentes seções das Avaliações Automatizadas.',
            attachTo: {
                element: '.main-sidebar',
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
                    text: 'Avançar'
                }
            ]
        });

        tour.addStep({
            title: 'Filtro de Mês',
            text: 'Selecione um mês para visualizar os dados do período correspondente. A página será atualizada automaticamente.',
            attachTo: {
                element: '.meses-container',
                on: 'bottom'
            },
            buttons: [
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
            title: 'Resumo Geral',
            text: 'Este painel apresenta um resumo dos principais indicadores, como o número de testes aplicados, conformidades e deficiências encontradas.',
            attachTo: {
                element: '.snci-resumo-geral',
                on: 'bottom'
            },
            buttons: [
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
            title: 'Detalhes do Indicador',
            text: 'Cada cartão mostra um indicador específico. Passe o mouse sobre o ícone de informação para ver a definição detalhada.',
            attachTo: {
                element: '.kpi-card:first-child',
                on: 'bottom'
            },
            buttons: [
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
            text: 'Este carrossel mostra o desempenho dos testes agrupados por assunto, comparando o mês atual com o anterior.',
            attachTo: {
                element: '.snci-desempenho-assunto',
                on: 'top'
            },
            buttons: [
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
            title: 'Navegação do Carrossel',
            text: 'Use estas setas para navegar entre os diferentes assuntos.',
            attachTo: {
                element: '.carousel-controls',
                on: 'top'
            },
            buttons: [
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
            text: 'Clique no ícone de olho para ver as evidências detalhadas dos eventos encontrados. O ícone aparece no canto superior direito do cartão.',
            attachTo: {
                element: '.performance-card.evidencias-clickable',
                on: 'top-end'
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