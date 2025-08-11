<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">

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

         /* Customizar largura dos popovers */
        .popover {
            max-width: 400px !important; /* Aumenta de ~276px para 400px */
            width: auto !important;
        }

        /* Para popovers muito grandes */
        .popover-large {
            max-width: 500px !important;
            width: auto !important;
        }

        /* Melhorar formatação do conteúdo do popover */
        .popover-body {
            font-size: 0.85rem;
            line-height: 1.4;
            padding: 12px 14px;
            word-wrap: break-word;
        }

        /* Ajustar largura da seta do popover */
        .popover .arrow::before {
            border-width: 0.5rem;
        }

    </style>

<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">
 
        <cfinclude template="includes/teste.cfm">
        
        <div class="content-wrapper">
            <section class="content">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-12">
                            <h3 class="m-3">Avaliação Geral - Deficiência do Controle
                            
                                <i class="fas fa-info-circle info-icon-automatizadas" style="position: relative;right: 3px;bottom: 13px;font-size: 1rem;" 
                                    data-toggle="popover" 
                                    data-trigger="hover" 
                                    data-placement="right"
                                    data-html="false"
                                    data-content="Tratam-se de situações identificadas nas avaliações realizadas nas unidades operacionais, por meio da aplicação de testes de controle (Plano de Testes), que não condizem com o previsto em normas internas dos Correios, documentos de orientações vigentes (ofícios) e legislações.">
                                </i>
                               
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
        });
    </script>
</body>
