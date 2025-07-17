<cfprocessingdirective pageencoding = "utf-8">

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
          
      <!-- Theme style -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/stylesSNCI.css">


    <style>
          .select2-container--bootstrap4 .select2-dropdown .select2-results__option[aria-selected="true"] {
            color: #fff!important;
            background-color:var(--azul_correios)!important
          }
          .select2-results__option{
            font-size:11px!important;
          }
          <cfif listLast(cgi.script_name, "/") eq "aa_Navegacao_por_abas.cfm">
           
          </cfif>

          /* Estilos modernos para o sidebar */
          .modern-sidebar {
            background: linear-gradient(135deg,var(--azul_claro_correios) 0%, var(--azul_correios) 100%);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            border-radius: 0 20px 20px 0;
            backdrop-filter: blur(10px);
          }

          .modern-nav-header {
            background: rgb(248 249 250);
            border-radius: 15px;
            margin: 15px;
            padding: 5px;
            text-align: center;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.2);
          }

          .modern-nav-header h3 {
            color: var(--azul_correios);
            font-weight: 600;
            margin: 0;
            font-size: 1.2rem;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
          }

          .modern-nav-link {
            margin: 8px 10px;
            padding: 10px 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            backdrop-filter: blur(5px);
            color: rgba(255, 255, 255, 0.9) !important;
            display: flex;
            align-items: center;
            text-decoration: none;
            position: relative;
            overflow: hidden;
          }

          .modern-nav-link::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
          }

          .modern-nav-link:hover::before {
            left: 100%;
          }

          .modern-nav-link:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateX(5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            color: #fff !important;
            border-color: rgba(255, 255, 255, 0.3);
          }

          .modern-nav-link.active {
            background: var(--amarelo_prisma_escuro_correios)!important;
            border-color: rgba(255, 255, 255, 0.4);
            transform: translateX(10px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
            color: var(--azul_correios)!important;
          }

          .modern-nav-link.active::after {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, #fff, rgba(255, 255, 255, 0.7));
            border-radius: 0 4px 4px 0;
          }

          .modern-nav-icon {
            width: 24px;
            height: 24px;
            margin-right: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            transition: all 0.3s ease;
            flex-shrink: 0;
          }

          .modern-nav-link:hover .modern-nav-icon {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
          }

          .modern-nav-text {
            font-weight: 500;
            font-size: 0.95rem;
            letter-spacing: 0.5px;
          }

          .modern-profile-section {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            margin: 15px;
            padding: 15px;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.2);
          }

          .modern-profile-section select {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: #fff;
            margin-bottom: 10px;
            transition: all 0.3s ease;
          }

          .modern-profile-section select:focus {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.4);
            box-shadow: 0 0 0 0.2rem rgba(255, 255, 255, 0.25);
          }

          .modern-profile-section select option {
            background: #333;
            color: #fff;
          }

          /* Scroll personalizado */
          .modern-sidebar::-webkit-scrollbar {
            width: 6px;
          }

          .modern-sidebar::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
          }

          .modern-sidebar::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 3px;
          }

          .modern-sidebar::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
          }

          /* Animações */
          @keyframes slideInLeft {
            from {
              transform: translateX(-100%);
              opacity: 0;
            }
            to {
              transform: translateX(0);
              opacity: 1;
            }
          }

          .modern-nav-link {
            animation: slideInLeft 0.5s ease forwards;
          }

          .modern-nav-link:nth-child(1) { animation-delay: 0.1s; }
          .modern-nav-link:nth-child(2) { animation-delay: 0.2s; }
          .modern-nav-link:nth-child(3) { animation-delay: 0.3s; }
          .modern-nav-link:nth-child(4) { animation-delay: 0.4s; }
          .modern-nav-link:nth-child(5) { animation-delay: 0.5s; }

          /* Responsive */
          @media (max-width: 768px) {
            .modern-sidebar {
              border-radius: 0;
            }
            
            .modern-nav-link {
              margin: 5px 10px!important
              padding: 10px 15px!important
            }
            
            .modern-nav-header,
            .modern-profile-section {
              margin: 10px!important
              padding: 15px!important
            }
          }
        
    </style>
</head>
<body>


      <!-- Main Sidebar Container -->
      <aside class="main-sidebar sidebar-dark-primary elevation-4 modern-sidebar" style="overflow-y: auto!important; height:100vh;">
        <!-- Sidebar -->
        <div class="sidebar os-host os-theme-light os-host-overflow os-host-resize-disabled os-host-transition os-host-overflow-y os-host-scrollbar-horizontal-hidden" style="height:100vh;">
         
          <!-- Header do Sidebar -->
          <div class="modern-nav-header">
            <h3>Páginas</h3>
            <!--<small style="color: rgba(255, 255, 255, 0.8); font-size: 0.85rem;">Sistema Nacional de Controle Interno</small>-->
          </div>

          <!---Se servidor não for de produção, aparecerá o select para alteração de perfil e lotação --->
          <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost2", application.auxsite)>
            <div class="modern-profile-section">
              <div class="form-group" style="margin-bottom: 0;">
                <select id="mudarPerfil" name="mudarPerfil" class="form-control" style="height:40px;">
                  <option selected="" disabled="" value="">Selecionar Perfil</option>
                  
                </select> 

                <select id="mudarLotacao" name="mudarLotacao" class="form-control" style="height:40px;">
                  <option selected="" disabled="" value="">Selecionar Unidade</option>
                  
                </select>   
              </div>
            </div>
          </cfif>

          <nav class="mt-3">
            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false" style="list-style: none; padding: 0;">
              <li class="nav-item" style="margin-bottom: 0;">
                <a href="index.cfm" class="nav-link modern-nav-link">
                  <div class="modern-nav-icon">
                    <i class="fas fa-tasks"></i>
                  </div>
                  <span class="modern-nav-text">Análises</span>
                </a>
              </li>
              <li class="nav-item" style="margin-bottom: 0;">
                <a href="teste.cfm" class="nav-link modern-nav-link">
                  <div class="modern-nav-icon">
                    <i class="fas fa-book"></i>
                  </div>
                  <span class="modern-nav-text">Termos e Definições</span>
                </a>
              </li>
              <li class="nav-item" style="margin-bottom: 0;">
                <a href="teste.cfm" class="nav-link modern-nav-link">
                  <div class="modern-nav-icon">
                    <i class="fas fa-vial"></i>
                  </div>
                  <span class="modern-nav-text">Testes Envolvidos</span>
                </a>
              </li>
              
              <!-- Exemplo de links adicionais que podem ser adicionados -->
              <li class="nav-item" style="margin-bottom: 0;">
                <a href="relatorios.cfm" class="nav-link modern-nav-link">
                  <div class="modern-nav-icon">
                    <i class="fas fa-chart-bar"></i>
                  </div>
                  <span class="modern-nav-text">Relatórios</span>
                </a>
              </li>
              <li class="nav-item" style="margin-bottom: 0;">
                <a href="configuracoes.cfm" class="nav-link modern-nav-link">
                  <div class="modern-nav-icon">
                    <i class="fas fa-cog"></i>
                  </div>
                  <span class="modern-nav-text">Configurações</span>
                </a>
              </li>
             
            </ul>
          </nav>
         
        </div>
        
      </aside>
  
    <!-- jQuery -->
    <script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery/jquery.min.js"></script>

    <!-- Bootstrap 4 -->
    <script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>

    <!-- jQuery UI 1.11.4 -->
    <script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery-ui/jquery-ui.min.js"></script>

    <!-- daterangepicker -->
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/moment/moment.min.js"></script>
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/daterangepicker/daterangepicker.js"></script>

    <!-- Chart.js-->
    <script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/chart.js/Chart.min.js"></script>

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
     
      //para sweetalert2
      const swalWithBootstrapButtons = Swal.mixin({
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger'
        },
        buttonsStyling: false
      })
      //fim const sweetalert2

      function logoSNCIsweetalert2(mens){
        let logo='';
        if(mens == ''){
          logo= '<div  class="logoDivSwal2Correios"><img src="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png"class="brand-image logoImagemSwal2Correios" >'
              + '<span class="font-weight-light azul_correios_textColor" style="font-size:20px!important;position:relative;top:3px">SNCI - Processos</span></div>';
        }else{
          logo= '<div  class="logoDivSwal2Correios"><img src="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png"class="brand-image logoImagemSwal2Correios" >'
              + '<span class="font-weight-light azul_correios_textColor " style="font-size:20px!important;width:100%;position:relative;top:3px">SNCI - Processos</span></div>'
              +'<div class="font-weight-light " style="margin-top:20px;color:#fff">'+ mens + '</div>';
        }

        return logo;
      }

      //Initialize Select2 Elements
      $('select').select2({
        theme: 'bootstrap4'
      });

      // Função moderna para destacar link ativo
      function setActiveLink() {
        const currentUrl = window.location.href;
        const navLinks = document.querySelectorAll('.modern-nav-link');
        
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.href === currentUrl) {
            link.classList.add('active');
          }
        });
      }

      // Efeito de hover melhorado
      $(document).ready(function() {
        $('.modern-nav-link').hover(
          function() {
            $(this).find('.modern-nav-icon').addClass('animate__animated animate__pulse');
          },
          function() {
            $(this).find('.modern-nav-icon').removeClass('animate__animated animate__pulse');
          }
        );

        // Definir link ativo
        setActiveLink();
      });

      // Obtem a URL atual da janela
      const url = window.location;

      // Seleciona todos os links dentro dos elementos com a classe 'nav-item'
      const allLinks = document.querySelectorAll('.nav-item a');

      // Filtra os links para encontrar o link que possui o mesmo 'href' da URL atual
      const currentLink = [...allLinks].filter(link => link.href === url.href);

      // Verifica se encontrou algum link correspondente
      if (currentLink.length > 0) {
        // Adiciona a classe 'active' ao link encontrado para destacá-lo como ativo
        currentLink[0].classList.add("active");

        // Itera sobre os elementos pai e os expande
        let parent = currentLink[0].closest(".nav-treeview");
        while (parent) {
          parent.style.display = "block";
          parent = parent.parentElement.closest(".nav-treeview");
        }

        // Verifica se o link está dentro de um elemento com a classe 'has-treeview'
        if (currentLink[0].closest(".has-treeview")) {
          // Se sim, adiciona a classe 'active' ao elemento para indicar que está ativo
          currentLink[0].closest(".has-treeview").classList.add("active");
        }
      } 

    <cfoutput>
      var #toScript(application.sessionTimeout*60*1000,"sTimeout")#
    </cfoutput>
    setTimeout('sessionWarning()', sTimeout);

    function sessionWarning() {
      //alert('Atenção: sua sessão foi encerrada por tempo de inatividade.');    
      window.location.href = "index.cfm";
    }

    //detectando o IE
    var txt = navigator.appName;
    if (txt == 'Microsoft Internet Explorer'){
      window.location.href = "navegadorNaoSuportado.html";
    }

    $(document).ready(function() {	//executa quando a página terminar de carregar
       
    });

		
  </script>

    
	
  </body>
</html>