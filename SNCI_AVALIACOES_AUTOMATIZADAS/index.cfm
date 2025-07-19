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
            flex: 3;
            display: flex;
            flex-direction: column;
            gap: 32px;
        }
        .sidebar {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 15px;
            text-align: center;
        }

        /* Card de Resumo Principal (Hero) */
        .hero-card {
            background: linear-gradient(135deg,var(--azul_claro_correios) 0%, var(--azul_correios) 100%);
            color: white;
            padding: 15px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            
        }
        .hero-card h1 {
            font-size: 2rem;
            font-weight: 700;
            margin: 0 0 10px 0;
        }
        
        .hero-summary {
            display: flex;
            align-items: center;
            gap: 16px;
            background-color: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 12px;
        }
        .hero-summary .icon {
            font-size: 2rem;
        }
        .hero-summary .text {
            font-size: 1.1rem;
            font-weight: 500;
        }
        .hero-summary .text strong {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--secondary-color);
        }

        /* Lista de Comparação Gráfica */
        .comparison-container {
            background: var(--card-bg-color);
            padding: 20px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }
        .comparison-container h2 {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0 0 24px 0;
        }
        .comparison-item {
            display: grid;
            grid-template-columns: 2fr 3fr 1fr;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
        }
        .comparison-item:last-child { border-bottom: none; }
        .item-title { font-weight: 500; }
        .item-bars .bar {
            height: 12px;
            border-radius: 6px;
            background-color: var(--border-color);
            transition: width 1.5s ease-in-out;
        }
        .item-bars .bar.maio { background-color: #a8dadc; }
        .item-bars .bar.junho { background-color: #457b9d; }
        .item-bars .label {
            display: flex;
            justify-content: space-between;
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-bottom: 6px;
        }
        .item-change {
            text-align: right;
        }
        .item-change .value {
            font-size: 1.1rem;
            font-weight: 600;
            display: block;
        }
        .item-change .status { font-size: 0.85rem; }
        .increase { color: var(--danger-color); }
        .decrease { color: var(--success-color); }

        /* Barra Lateral de KPIs */
        .sidebar h2 {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0;
        }
        .kpi-card {
            background: var(--card-bg-color);
            padding: 20px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 16px;
            text-align: left;
        }
        .kpi-card .icon {
            font-size: 1.5rem;
            color: var(--primary-color);
            background-color: rgba(0, 51, 102, 0.1);
            height: 48px;
            width: 48px;
            border-radius: 12px;
            display: grid;
            place-items: center;
        }
        .kpi-card .text .title {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }
        .kpi-card .text .value {
            font-size: 1.5rem;
            font-weight: 600;
        }

        /* Responsividade */
        @media (max-width: 1200px) {
            .dashboard-layout {
                flex-direction: column;
            }
            .comparison-item {
                grid-template-columns: 1fr;
                gap: 16px;
            }
            .item-change { text-align: left; }
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
                        <div class="hero-card">
                            <div class="hero-summary">
                                <div class="icon"><i class="fas fa-chart-line increase"></i></div>
                                <div class="text">
                                    Em Junho, o total de eventos com deficiências do controle <strong>aumentou 32%</strong> em relação ao mês anterior.
                                </div>
                            </div>
                        </div>

                        <div class="comparison-container">
                             <h2>Desempenho por Assunto</h2>
                             <div class="comparison-item">
                                <div class="item-title">Pendências no PROTER</div>
                                <div class="item-bars">
                                    <div class="label"><span>Maio</span> <span>26.879</span></div>
                                    <div class="bar maio animated-bar" data-width="97.5%"></div>
                                    <div class="label" style="margin-top:8px;"><span>Junho</span> <span>27.543</span></div>
                                    <div class="bar junho animated-bar" data-width="100%"></div>
                                </div>
                                <div class="item-change increase">
                                    <span class="value">↑ 664</span>
                                    <span class="status">Aumentou 2%</span>
                                </div>
                             </div>
                             <div class="comparison-item">
                                <div class="item-title">Funcionamento do alarme</div>
                                <div class="item-bars">
                                    <div class="label"><span>Maio</span> <span>6.391</span></div>
                                    <div class="bar maio animated-bar" data-width="95.9%"></div>
                                    <div class="label" style="margin-top:8px;"><span>Junho</span> <span>6.663</span></div>
                                    <div class="bar junho animated-bar" data-width="100%"></div>
                                </div>
                                <div class="item-change increase">
                                    <span class="value">↑ 272</span>
                                    <span class="status">Aumentou 4%</span>
                                </div>
                             </div>
                             <div class="comparison-item">
                                <div class="item-title">Embarque e desembarque da carga</div>
                                <div class="item-bars">
                                    <div class="label"><span>Maio</span> <span>2.255</span></div>
                                    <div class="bar maio animated-bar" data-width="42.8%"></div>
                                    <div class="label" style="margin-top:8px;"><span>Junho</span> <span>5.267</span></div>
                                    <div class="bar junho animated-bar" data-width="100%"></div>
                                </div>
                                <div class="item-change increase">
                                    <span class="value">↑ 3.012</span>
                                    <span class="status">Aumentou 134%</span>
                                </div>
                             </div>
                             <div class="comparison-item">
                                <div class="item-title">CNH vencida há mais de 30 dias</div>
                                <div class="item-bars">
                                    <div class="label"><span>Maio</span> <span>6.017</span></div>
                                    <div class="bar maio animated-bar" data-width="100%"></div>
                                    <div class="label" style="margin-top:8px;"><span>Junho</span> <span>5.207</span></div>
                                    <div class="bar junho animated-bar" data-width="86.5%"></div>
                                </div>
                                <div class="item-change decrease">
                                    <span class="value">↓ 810</span>
                                    <span class="status">Reduziu 13%</span>
                                </div>
                             </div>
                        </div>
                    </div>

                    <div class="sidebar">
                        <h2>Resumo Geral</h2>
                        
                         <div class="kpi-card">
                            <div class="icon"><i class="fas fa-tasks"></i></div>
                            <div class="text">
                                <div class="title">Testes Aplicados</div>
                                <div class="value animated-number" data-target="123552">0</div>
                            </div>
                        </div>
                        <div class="kpi-card">
                            <div class="icon"><i class="fas fa-check-circle decrease"></i></div>
                            <div class="text">
                                <div class="title">Conformes</div>
                                <div class="value animated-number" data-target="94094">0</div>
                            </div>
                        </div>
                         <div class="kpi-card">
                            <div class="icon"><i class="fas fa-exclamation-triangle increase"></i></div>
                            <div class="text">
                                <div class="title">Deficiência do Controle</div>
                                <div class="value animated-number" data-target="29458">0</div>
                            </div>
                        </div>
                        <div class="kpi-card">
                            <div class="icon"><i class="fas fa-chart-bar"></i></div>
                            <div class="text">
                                <div class="title">Total de Eventos</div>
                                <div class="value animated-number" data-target="1947292">0</div>
                            </div>
                        </div>
                        <div class="kpi-card">
                            <div class="icon"><i class="fas fa-dollar-sign"></i></div>
                            <div class="text">
                                <div class="title">Valor Envolvido</div>
                                <div class="value">R$ <span class="animated-number" data-target="79256842">0</span></div>
                            </div>
                        </div>
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

            // Animação de contagem para os números
            $('.animated-number').each(function() {
                var $this = $(this);
                var target = parseInt($this.data('target'));
                $({ countNum: 0 }).animate({
                    countNum: target
                }, {
                    duration: 1500,
                    easing: 'swing',
                    step: function() {
                        $this.text(Math.floor(this.countNum).toLocaleString('pt-BR'));
                    },
                    complete: function() {
                        $this.text(this.countNum.toLocaleString('pt-BR'));
                    }
                });
            });

            // Animação para as barras de progresso
            $('.animated-bar').each(function(){
                var $this = $(this);
                var targetWidth = $this.data('width');
                $this.css('width', '0%').animate({
                    width: targetWidth
                }, 1500, 'swing');
            });

            // Efeito de fade-in para os cards
            $('.hero-card, .comparison-container, .kpi-card').each(function(i){
                $(this).css({opacity: 0, transform: 'translateY(20px)'}).delay(i * 100).animate({
                    opacity: 1,
                    transform: 'translateY(0)'
                }, 600, 'swing');
            });
        });
    </script>
</body>

</html>