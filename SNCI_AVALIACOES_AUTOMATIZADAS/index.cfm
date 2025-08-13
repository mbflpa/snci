<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    <style>
        .display-5 {
            font-size: 2rem!important;
            font-weight: 300!important;
            line-height: 1.2!important;
        }

        /* Iframe tab bar container */
        .iframe-mode .nav.navbar {
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
        }

        /* Modern tab styles */
        .iframe-mode .navbar-nav .nav-link {
            border: 0;
            padding: 0.75rem 1rem; /* Aumentar um pouco o padding para toque */
            padding-top:0.3rem!important;
            padding-bottom:0.3rem!important;
            font-size: 0.9rem;
            color: #6c757d;
            border-bottom: 3px solid transparent;
            transition: all 0.2s ease-in-out;
            margin: 0 2px;
            border-radius: 10px 10px 0 0;
        }

        .iframe-mode .navbar-nav .nav-link:hover {
            color: #007bff;
            background-color: #f8f9fa;
            border-bottom-color: #dee2e6;
        }

        .iframe-mode .navbar-nav .nav-link.active {
            font-weight: 600;
            color:  var(--azul_correios)!important;
            background-color: var(--amarelo_prisma_escuro_correios)!important;
            border-bottom-color:  var(--azul_correios)!important;
        }
        
        .iframe-mode .navbar-nav .nav-link.active::after {
            content: none; /* remove the triangle */
        }

        /* Compact and modern control buttons */
        .iframe-mode .navbar-light .nav-link[data-widget],
        .iframe-mode .navbar-light .dropdown-toggle {
            padding: 0.5rem 0.75rem;
            font-size: 1rem;
            color: #6c757d;
            border-radius: 4px;
        }

        .iframe-mode .navbar-light .nav-link[data-widget]:hover,
        .iframe-mode .navbar-light .dropdown-toggle:hover {
            color: #007bff;
            background-color: #e9ecef;
        }

        /* Dropdown icon for closing tabs */
        .iframe-mode .dropdown-toggle i {
            font-size: 1.1rem;
        }
    </style>   
</head>
<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
     
      
    <div class="wrapper">
         <cfinclude template="includes/aa_navBar.cfm">
        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper iframe-mode" data-widget="iframe" >
            <div class="nav navbar navbar-expand navbar-white navbar-light border-bottom p-0">
            <div class="nav-item dropdown">
                <a class="nav-link bg-danger dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">Fechar</a>
                <div class="dropdown-menu mt-0">
                    <a class="dropdown-item" href="#" data-widget="iframe-close" data-type="all">
                        <i class="fas fa-times-circle" ></i> Fechar todas as páginas
                    </a>
                    <a class="dropdown-item" href="#" data-widget="iframe-close" data-type="all-other">
                        <i class="far fa-times-circle"></i> Fechar outras páginas
                    </a>
                   
                </div>
            </div>
                <a class="nav-link bg-light" href="#" data-widget="iframe-scrollleft"><i class="fas fa-angle-double-left"></i></a>
                <ul class="navbar-nav overflow-hidden" role="tablist"></ul>
                <a class="nav-link bg-light" href="#" data-widget="iframe-scrollright"><i class="fas fa-angle-double-right"></i></a>
                <a class="nav-link bg-light" href="#" data-widget="iframe-fullscreen"><i class="fas fa-expand"></i></a>
            </div>
            <div class="tab-content">
                <div class="tab-empty">
                    <div class="display-5">Clique em um link no menu ao lado para incluir aqui!</div>
                </div>
            </div>
        </div>
    </div>
    <!-- Footer -->
    <cfinclude template="includes/aa_footer.cfm">   
	</div>
	<!-- ./wrapper -->
    <cfinclude template="includes/aa_sidebar.cfm">

    <script>
        $(document).ready(function() {
            if (window.location.pathname.toLowerCase().includes('aa_navegacao_por_abas.cfm')) {
                $('a[href*="aa_navegacao_por_abas.cfm"]').closest('li').remove();
            }

            // Monitorar fechamento de abas e desativar links do sidebar se não houver abas abertas
            $(document).on('click', '[data-widget="iframe-close"]', function() {
                setTimeout(function() {
                    // Se não houver mais abas abertas
                    if ($('.tab-content .tab-pane').length === 0 || $('.tab-content .tab-pane.active').length === 0) {
                        $('.modern-nav-link').removeClass('active');
                    }
                }, 300);
            });
        });
    </script>
    
</body>
</html>