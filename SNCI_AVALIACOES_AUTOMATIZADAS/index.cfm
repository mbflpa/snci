<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">

<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI - Dashboard de Análise</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    
    <style>
        :root {
            --primary-color: #003366;
            --secondary-color: #FFD200;
            --danger-color: #e63946;
            --success-color: #2a9d8f;
            --bg-color: #f7f8fc;
            --card-bg-color: #ffffff;
            --text-primary: #1e293b;
            --text-secondary: #64748b;
            --border-color: #e2e8f0;
            --border-radius: 16px;
            --shadow: 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05);
        }
        
        body {
            font-family: 'Poppins', Arial, sans-serif;
            background: var(--bg-color);
            margin: 0;
            color: var(--text-primary);
        }
        
        .content-wrapper {
            background-color: transparent !important;
        }
        
        /* Layout principal do Dashboard */
        .dashboard-layout {
            display: flex;
            gap: 32px;
            padding: 16px;
        }
        
        .main-content {
            flex: 5;
        }
        
        .sidebar {
            flex: 1;
        }

        /* Responsividade */
        @media (max-width: 1200px) {
            .dashboard-layout {
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
                <div class="dashboard-layout">
                    <div class="main-content">                       
                        <!--- Incluir componente de Desempenho por Assunto --->
                        <cfinclude template="includes/componentes_deficiencias_controle/desempenho_assunto2.cfm">
                    </div>

                    <div class="sidebar">
                        <!--- Componente de Resumo Geral --->
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