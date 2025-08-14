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


        /*TOUR*/  
        /* Modern and fluid Shepherd.js styles using Correios color palette */
        .shepherd-element {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif!important;
            background: #fff!important;
            border-radius: 8px!important;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15)!important;
            max-width: 380px!important;
            opacity: 0!important;
            transform: scale(0.95) translateY(10px)!important;
            transition: opacity 0.3s ease-in-out, transform 0.3s ease-in-out!important
        }

        .shepherd-element.shepherd-enabled {
            opacity: 1!important;
            transform: scale(1) translateY(0)!important;
        }

        .shepherd-header {
            background: linear-gradient(135deg, var(--azul_correios, #00416B), var(--azul_claro_correios, #0083CA))!important;
            color: #fff!important;
            padding: 0.75rem 1rem!important;
            border-top-left-radius: 7px!important;
            border-top-right-radius: 7px!important;
        }
     

        .shepherd-title {
            font-weight: 600!important;
            font-size: 1rem!important;
            color: #fff!important;
           
        }

        .shepherd-text {
            padding: 1rem!important;
            color: #495057!important;
            font-size: 0.9rem!important;
            line-height: 1.6!important;
            text-align: justify!important;
        }

        .shepherd-footer {
            border-top: 1px solid #dee2e6!important;
            padding: 0.75rem 1rem!important;
            justify-content: space-between!important;

        .shepherd-button {
            background: var(--amarelo_prisma_escuro_correios, #FFC20E)!important;
            color: var(--azul_correios, #00416B)!important;
            border: none!important;
            border-radius: 5px!important;
            padding: 0.5rem 1rem!important;
            font-weight: bold!important;
            transform: translateY(0)!important;
            transition: all 0.2s ease!important;
        }

        .shepherd-button:hover {
            background: var(--amarelo_correios, #FFD400)!important;
            transform: translateY(-2px)!important;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1)!important;
        }

        .shepherd-button.shepherd-button-secondary {
            background: #e9ecef!important;
            color: #495057!important;
        }

        .shepherd-button.shepherd-button-secondary:hover {
            background: #ced4da!important;
        }

        .shepherd-cancel-icon {
            color: #fff!important;
            opacity: 0.8!important;
        }
        .shepherd-cancel-icon:hover {
            opacity: 1!important;
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
            text: 'Este painel apresenta diferentes métricas, acumuladas de jan do ano atual até o mês selecionado no filtro.',
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
            title: 'Cartão da Métrica',
            text: 'Cada cartão mostra uma métrica específica. Passe o mouse sobre o ícone  <strong><i class="fa-regular fa-circle-question"></i></strong> para ver a definição detalhada.<br> Obs.: Em qualquer elemento desta página, sempre que este ícone for exibido, você pode obter mais informações sobre métricas, definições, explicações, dados extras, etc.',
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
            text: 'Este carrossel mostra o desempenho dos testes agrupados por assunto, comparando o mês atual com o anterior.',
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
            title: 'Navegação do Carrossel',
            text: 'Use estas setas para navegar entre os diferentes assuntos ou use a barra de rolagem.',
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
            text: 'Quando o ícone <i class="fa-solid fa-eye"></i> estiver visível, clique no cartão para ver as evidências detalhadas dos respectivos eventos. O ícone aparece no canto superior direito do cartão.',
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
            text: 'Assuntos reincidentes são aqueles com, pelo menos, um evento aparecendo no mês atual e também no mês anterior.',
            attachTo: {
                element: '.badge-reincidente',
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
            title: 'Valor Envolvido',
            text: 'Sempre que eventos do assunto apresentarem valores envolvidos, o total do mês será exibido no cartão correspondente.',
            attachTo: {
                element: '.valor-envolvido',
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
            title: 'Informações sobre o Assunto',
            text: 'Dê especial atenção às informações apresentadas neste ícone <strong><i class="fa-regular fa-circle-question"></i></strong>. Ele mostra detalhes importantes sobre o assunto.',
            attachTo: {
                element: '.card-title',
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
            title: 'Fim do tour',
            text: 'Chegamos ao final desse tour. Sempre que desejar, você pode reiniciá-lo clicando neste botão.',
            attachTo: {
                element: '#startTourBtn',
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