<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/pc_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/pc_modal_preloader.cfm">
<!DOCTYPE html>
<html lang="pt-br">
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/animate.min.css">
<!-- Font Awesome -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/fontawesome-free/css/fontawesome.min.css">
	<!-- Tempusdominus Bootstrap 4 -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
	
	
	<!-- overlayScrollbars -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
	<!-- Daterange picker -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/daterangepicker/daterangepicker.css">

	<!-- SweetAlert2 -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.css">
	<!-- Toastr -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/toastr/toastr.css">
	<!-- Bootstrap4 Duallistbox -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap4-duallistbox/bootstrap-duallistbox.css">
	<!-- Select2 -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2/css/select2.min.css">
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">
 
  <!-- DataTables -->
  <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/datatables/datatables.min.css">
	

	<!-- Tour 
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/tour/dist/css/hopscotch.css">-->

  <!-- Theme style -->
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/adminlte.min.css">
	<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/stylesSNCI.css">

    <style>
        body {
            font-family: 'Roboto', Arial, sans-serif;
            background: #f4f4f4;
            margin: 0;
            color: #003366;
        }
        header {
            background: linear-gradient(90deg, #003366 70%, #FFD200 100%);
            color: #fff;
            padding: 24px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .logo {
            height: 56px;
            margin-right: 24px;
        }
        .app-title {
            font-size: 2.2rem;
            font-weight: 700;
            letter-spacing: 1px;
        }
        main {
            padding: 32px;
            max-width: 1200px;
            margin: 0 auto;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 32px;
        }
        .card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07);
            padding: 24px;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            transition: box-shadow 0.2s;
        }
        .card:hover {
            box-shadow: 0 4px 24px rgba(0,0,0,0.13);
        }
        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 12px;
            color: #FFD200;
        }
        .card-title {
            font-size: 1.2rem;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .card-value {
            font-size: 2rem;
            font-weight: 700;
            color: #003366;
            margin-bottom: 16px;
        }
        .chart-placeholder {
            width: 100%;
            height: 120px;
            background: linear-gradient(90deg, #FFD200 30%, #003366 100%);
            border-radius: 8px;
            opacity: 0.15;
            margin-bottom: 8px;
        }
        @media (max-width: 700px) {
            header, main {
                padding: 16px;
            }
            .app-title {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
    
	<div class="wrapper">
        <cfinclude template="includes/pc_navBar.cfm">
        <div class="content-wrapper" >
             <section class="content-header">
                <div class="container-fluid">
                        <div class="dashboard-grid">
                            <div class="card">
                                <div class="card-icon">&#128202;</div>
                                <div class="card-title">Avaliações Realizadas</div>
                                <div class="card-value" id="avaliacoesRealizadas">1.245</div>
                                <div class="chart-placeholder"></div>
                            </div>
                            <div class="card">
                                <div class="card-icon">&#128200;</div>
                                <div class="card-title">Pendentes</div>
                                <div class="card-value" id="avaliacoesPendentes">87</div>
                                <div class="chart-placeholder"></div>
                            </div>
                            <div class="card">
                                <div class="card-icon">&#128176;</div>
                                <div class="card-title">Performance Média</div>
                                <div class="card-value" id="performanceMedia">92%</div>
                                <div class="chart-placeholder"></div>
                            </div>
                            <div class="card">
                                <div class="card-icon">&#128197;</div>
                                <div class="card-title">Última Atualização</div>
                                <div class="card-value" id="ultimaAtualizacao">10/06/2024</div>
                                <div class="chart-placeholder"></div>
                            </div>
                        </div>
                </div>
            </section>
        </div>

        <!-- Footer -->
        <cfinclude template="includes/pc_footer.cfm">
   
    <!-- jQuery -->
		<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery/jquery.min.js"></script>

		<!-- Bootstrap 4 -->
		<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>

		<!-- jQuery UI 1.11.4 -->
		<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery-ui/jquery-ui.min.js"></script>
 
  
    
		<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
		<script language="JavaScript">
	    $.widget.bridge('uibutton', $.ui.button)
		</script>

        <!-- daterangepicker -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/moment/moment.min.js"></script>
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/daterangepicker/daterangepicker.js"></script>

		<!-- Tempusdominus Bootstrap 4 -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"></script>

		<!-- overlayScrollbars -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
        <!-- Select2 -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2/js/select2.full.min.js"></script>

		<!-- InputMask -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/inputmask/jquery.inputmask.min.js"></script>
<!-- SweetAlert2 -->
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/sweetalert2/sweetalert2.min.js"></script>

    <!-- Toastr -->
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/toastr/toastr.min.js"></script>

     


    <!-- DataTables  & Plugins -->
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/datatables/datatables.min.js"></script>
    	
<!-- Bootstrap -->
    <script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
   <!-- AdminLTE App -->
		<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/js/adminlte.min.js"></script>
 
     <script language="JavaScript">
        // Exemplo de interatividade: animação dos valores
        $(document).ready(function(){
            $('.card-value').each(function(){
                $(this).css({opacity:0, position:'relative', top:'20px'})
                    .animate({opacity:1, top:'0px'}, 700);
            });
            $('#modalOverlay').modal('hide');
        });
    </script>
</body>
</html>
