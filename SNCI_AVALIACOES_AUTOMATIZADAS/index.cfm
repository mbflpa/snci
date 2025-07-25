<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">

<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI - deficiencias-geral de Análise</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    
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
</head>
<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">
        <cfinclude template="includes/aa_navBar.cfm">
        <cfinclude template="includes/aa_sidebar.cfm">
        
        <div class="content-wrapper">
            <section class="content">
    
                <!--<div style="width: 100%; padding: 0 16px; margin-bottom: 16px;">
                    <cfinclude template="includes/componentes_deficiencias_controle/mensagem_card.cfm">
                </div>-->
 
                <div class="deficiencias-geral-layout">
                    <div class="dashboard-main-content">
                        <cfinclude template="includes/componentes_deficiencias_controle/desempenho_assunto.cfm">
                    </div>
                    <div class="dashboard-kpi-panel">
                        <cfinclude template="includes/componentes_deficiencias_controle/resumo_geral.cfm">
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

</html>