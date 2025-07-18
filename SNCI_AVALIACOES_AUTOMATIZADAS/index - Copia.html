<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">
<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    
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
<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">
        <cfinclude template="includes/aa_navBar.cfm">
        <cfinclude template="includes/aa_sidebar.cfm">
        <div class="content-wrapper" >
             <section class="content-header">
                <div class="container-fluid">
                    <!-- Controles do Dashboard -->
                    <div class="dashboard-controls" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                        <div class="dashboard-pagination">
                            <button id="btnPrev" class="btn btn-outline-secondary btn-sm"><i class="fas fa-chevron-left"></i></button>
                            <span id="currentPeriod" style="margin: 0 10px; font-size: 1.1rem;">Período: Jan 2024</span>
                            <button id="btnNext" class="btn btn-outline-secondary btn-sm"><i class="fas fa-chevron-right"></i></button>
                        </div>
                        <div class="dashboard-filter">
                            <select id="filterCategory" class="form-control form-control-sm">
                                <option value="all">Todas Categorias</option>
                                <option value="avaliacoes">Avaliações</option>
                                <option value="pendentes">Pendentes</option>
                                <option value="performance">Performance</option>
                            </select>
                        </div>
                    </div>
                    <!-- Grid do Dashboard -->
                    <div class="dashboard-grid">
                        <!-- Card 1 -->
                        <div class="card animate__animated animate__fadeInUp">
                            <div class="card-icon"><i class="fas fa-chart-bar"></i></div>
                            <div class="card-title">Avaliações Realizadas</div>
                            <div class="card-value" id="avaliacoesRealizadas">1.245</div>
                        </div>
                        <!-- Card 2 -->
                        <div class="card animate__animated animate__fadeInUp" style="animation-delay:1.1s;">
                            <div class="card-icon"><i class="fas fa-tasks"></i></div>
                            <div class="card-title">Pendentes</div>
                            <div class="card-value" id="avaliacoesPendentes">87</div>
                        </div>
                        <!-- Card 3 -->
                        <div class="card animate__animated animate__fadeInUp" style="animation-delay:1.2s;">
                            <div class="card-icon"><i class="fas fa-percent"></i></div>
                            <div class="card-title">Performance Média</div>
                            <div class="card-value" id="performanceMedia">92%</div>
                        </div>
                        <!-- Card 4 -->
                        <div class="card animate__animated animate__fadeInUp" style="animation-delay:1.3s;">
                            <div class="card-icon"><i class="fas fa-calendar-alt"></i></div>
                            <div class="card-title">Última Atualização</div>
                            <div class="card-value" id="ultimaAtualizacao">10/06/2024</div>
                        </div>
                        <!-- Card 5 -->
                        <div class="card animate__animated animate__fadeInUp" style="animation-delay:1.4s;">
                            <div class="card-icon"><i class="fas fa-users"></i></div>
                            <div class="card-title">Usuários Ativos</div>
                            <div class="card-value" id="usuariosAtivos">532</div>
                        </div>
                        <!-- Card 6 -->
                        <div class="card animate__animated animate__fadeInUp" style="animation-delay:1.5s;">
                            <div class="card-icon"><i class="fas fa-dollar-sign"></i></div>
                            <div class="card-title">Receita Total</div>
                            <div class="card-value" id="receitaTotal">R$ 45.600</div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <!-- Footer -->
        <cfinclude template="includes/aa_footer.cfm">
   </div>
    
 
    <script language="JavaScript">
        // Exemplo de interatividade: animação dos valores
        $(document).ready(function(){
            //Resolve conflict in jQuery UI tooltip with Bootstrap tooltip 
            $.widget.bridge('uibutton', $.ui.button)

            $('.card-value').each(function(){
                $(this).css({opacity:0, position:'relative', top:'20px'})
                    .animate({opacity:1, top:'0px'}, 700);
            });
            
            $('#modalOverlay').modal('hide');

            var currentIndex = 0;
            var periods = ["Jan 2024", "Fev 2024", "Mar 2024"];
            function updateDashboard() {
                $("#currentPeriod").text("Período: " + periods[currentIndex]);
                // Substitua os valores fictícios por variáveis ColdFusion ou recupere via AJAX
                $("#avaliacoesRealizadas").text(1245 + currentIndex);
                $("#avaliacoesPendentes").text(87 + currentIndex);
                $("#performanceMedia").text((92 - currentIndex) + "%");
                $("#ultimaAtualizacao").text("10/06/2024");
                $("#usuariosAtivos").text(532 + currentIndex);
            }
            $("#btnPrev").click(function(){
                if(currentIndex > 0){
                    currentIndex--;
                    updateDashboard();
                }
            });
            $("#btnNext").click(function(){
                if(currentIndex < periods.length - 1){
                    currentIndex++;
                    updateDashboard();
                }
            });
            updateDashboard();
        });
    </script>
</body>

</body>
</html>
