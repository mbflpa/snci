<cfprocessingdirective pageencoding = "utf-8">

    <style>
       
        
        .deficiencias-geral-layout {
            display: flex;
            padding: 16px;
            align-items: flex-start; /* Alinha os itens ao topo */
            flex-wrap: nowrap; /* Garante que os itens não quebrem para a próxima linha */
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
            width: 65%; /* Adjust as needed */
            flex: none; /* Remove flex shorthand for testing */
        }

        .dashboard-kpi-panel {
            width: 35%; /* Adjust as needed */
            flex: none; /* Remove flex shorthand for testing */
        }

        /* Responsividade */
        @media (max-width: 1200px) {
            .deficiencias-geral-layout {
                flex-direction: column;
            }
        }
    </style>

<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">

        
        <div class="content-wrapper" >
            <section class="content">
   
                <div style="width: 100%; padding: 0 16px; margin-bottom: 16px;">
                    <!--<cfinclude template="includes/componentes_deficiencias_controle/def_controle_mensagem_card.cfm">-->
                </div>
               
                    <div class="alert alert-info shadow-lg rounded d-flex align-items-start p-4" role="alert" style="background-color: #e9f7fd; border-left: 5px solid #17a2b8;margin-top:120px">
                        <i class="fas fa-lightbulb mr-3" style="font-size: 1.8rem; color: #17a2b8;margin-top: 10px;"></i>
                        <div>
                        <h5 class="mb-1 font-weight-bold" style="color: #0c5460;">Interpretação Simplificada</h5>
                        <p class="mb-0" style="font-size: 1rem;color: #0c5460;">
                            Esta página transformará dados dos dashboards em explicações claras e acessíveis para as unidades.
                        </p>
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

