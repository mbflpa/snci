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
    </style>   
</head>
<body class="hold-transition sidebar-mini layout-fixed" data-panel-auto-height-mode="height">
     
      
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
           
        });
        
    </script>
    
</body>
</html>