<cfprocessingdirective pageencoding="utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">

<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>SNCI - Página em Construção</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png" />

    <style>
        :root {
            --azul_claro_correios: #2980b9;
        }

        /* --- seu CSS original aqui, exceto a progress bar que vamos substituir --- */
        .construcao-container {
            min-height: calc(100vh - 200px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
            background: transparent;
            position: relative;
            overflow: hidden;
        }

        .construcao-content {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 1rem;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
            max-width: 600px;
            width: 100%;
            position: relative;
            z-index: 2;
            animation: fadeInUp 1s ease-out;
        }

        .construcao-icon {
            font-size: 5rem;
            color: var(--azul_claro_correios);
            margin-bottom: 1.5rem;
            animation: bounce 2s infinite;
        }

        .construcao-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #343a40;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, var(--azul_claro_correios), #1e73a7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .construcao-subtitle {
            font-size: 1.2rem;
            color: #6c757d;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .construcao-features {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 0.8rem;
            margin: 2rem 0;
        }

        .feature-item {
            padding: 0.8rem 0.5rem;
            border-radius: 8px;
            background: rgba(41, 128, 185, 0.1);
            border: 2px solid rgba(41, 128, 185, 0.2);
            transition: all 0.3s ease;
        }

        .feature-item:hover {
            transform: translateY(-5px);
            background: rgba(41, 128, 185, 0.15);
            border-color: rgba(41, 128, 185, 0.4);
        }

        .feature-icon {
            font-size: 1.5rem;
            color: var(--azul_claro_correios);
            margin-bottom: 0.3rem;
        }

        .feature-text {
            font-size: 0.75rem;
            color: #495057;
            font-weight: 600;
        }

        /* --- Barra de progresso indeterminada tipo Windows 11 --- */
        .progress-container {
            margin: 2rem 0;
        }

        .progress-label {
            font-size: 1rem;
            color: #495057;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .progress-bar-custom {
            position: relative;
            width: 100%;
            height: 14px;
            background: rgba(41, 128, 185, 0.12);
            border-radius: 999px;
            overflow: hidden;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.3);
        }

        .progress-indeterminate {
            position: absolute;
            top: 0;
            left: -30%; /* começa fora da barra, esquerda */
            height: 100%;
            width: 30%; /* tamanho da barra que desliza */
            background: linear-gradient(90deg, var(--azul_claro_correios), #1e73a7);
            border-radius: 999px;
            overflow: hidden;
            animation: indeterminateMove 2s linear infinite;
            transform: translateZ(0);
        }

        /* zigzag overlay */
        .progress-indeterminate::before {
            content: "";
            position: absolute;
            inset: 0;
            background-image: linear-gradient(
                135deg,
                rgba(255, 255, 255, 0.14) 0%,
                rgba(255, 255, 255, 0.14) 12.5%,
                rgba(255, 255, 255, 0) 12.5%,
                rgba(255, 255, 255, 0) 25%
            );
            background-size: 40px 40px;
            transform: skewX(-20deg) translateX(-40px) translateZ(0);
            mix-blend-mode: overlay;
            animation: zigzagMove 1.2s linear infinite;
            pointer-events: none;
            opacity: 0.95;
        }

        /* brilho suave */
        .progress-indeterminate::after {
            content: "";
            position: absolute;
            top: -40%;
            left: -40%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle at 10% 20%, rgba(255, 255, 255, 0.06), transparent 8%);
            animation: subtleShine 3.2s ease-in-out infinite;
            pointer-events: none;
        }

        @keyframes indeterminateMove {
            0% {
                left: -30%;
            }

            100% {
                left: 100%;
            }
        }

        @keyframes zigzagMove {
            0% {
                transform: skewX(-20deg) translateX(-40px);
            }

            100% {
                transform: skewX(-20deg) translateX(120%);
            }
        }

        @keyframes subtleShine {
            0% {
                transform: translateX(-10%) translateY(0) scale(1);
                opacity: 0.9;
            }

            50% {
                transform: translateX(10%) translateY(0) scale(1.02);
                opacity: 0.6;
            }

            100% {
                transform: translateX(-10%) translateY(0) scale(1);
                opacity: 0.9;
            }
        }

        /* Outras animações e responsividade originais */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes bounce {
            0%,
            20%,
            50%,
            80%,
            100% {
                transform: translateY(0);
            }

            40% {
                transform: translateY(-20px);
            }

            60% {
                transform: translateY(-10px);
            }
        }

        /* Responsividade */
        @media (max-width: 768px) {
            .construcao-content {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }

            .construcao-title {
                font-size: 2rem;
            }

            .construcao-subtitle {
                font-size: 1rem;
            }

            .construcao-icon {
                font-size: 4rem;
            }

            .construcao-features {
                grid-template-columns: repeat(2, 1fr);
                gap: 1rem;
            }
        }

        @media (max-width: 576px) {
            .construcao-title {
                font-size: 1.8rem;
            }

            .construcao-icon {
                font-size: 3.5rem;
            }

            .construcao-features {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
        }
    </style>
</head>

<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">

    <div class="wrapper">
         <cfinclude template="includes/aa_sidebar.cfm">

        <div class="content-wrapper">
            <section class="content p-0">
                <div class="construcao-container">
                    <div class="construcao-content">
                        <div class="construcao-icon">
                            <i class="fas fa-hammer"></i>
                        </div>

                        <h1 class="construcao-title">
                            Página em Construção
                        </h1>

                        <p class="construcao-subtitle">
                            Estamos trabalhando para trazer novos recursos e melhorias para o sistema SNCI.
                            Esta funcionalidade estará disponível em breve!
                        </p>

                        <div class="construcao-features">
                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fas fa-paint-brush"></i>
                                </div>
                                <div class="feature-text">
                                    Design Moderno
                                </div>
                            </div>

                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fas fa-mobile-alt"></i>
                                </div>
                                <div class="feature-text">
                                    Responsivo
                                </div>
                            </div>

                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fas fa-shield-alt"></i>
                                </div>
                                <div class="feature-text">
                                    Seguro
                                </div>
                            </div>

                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fas fa-tachometer-alt"></i>
                                </div>
                                <div class="feature-text">
                                    Performático
                                </div>
                            </div>
                        </div>

                        <div class="progress-container">
                            <div class="progress-label">
                                Progresso do Desenvolvimento
                            </div>
                            <div class="progress-bar-custom">
                                <div class="progress-indeterminate"></div>
                            </div>
                        </div>

                        <a href="javascript:history.back()" class="btn-voltar" style="display:inline-block; margin-top:1rem; font-weight:600; color: var(--azul_claro_correios); text-decoration:none;">
                            <i class="fas fa-arrow-left me-2"></i>
                            Voltar à Página Anterior
                        </a>
                    </div>
                </div>
            </section>
        </div>

        <cfinclude template="includes/aa_footer.cfm" />
    </div>

    <script language="JavaScript">
        $(document).ready(function () {
            $.widget.bridge('uibutton', $.ui.button);
            $('#modalOverlay').modal('hide');

            // Adicionar efeito de hover nos feature items
            $('.feature-item').on('mouseenter', function () {
                $(this).find('.feature-icon').addClass('fa-bounce');
            }).on('mouseleave', function () {
                $(this).find('.feature-icon').removeClass('fa-bounce');
            });
        });
    </script>
</body>

</html>
