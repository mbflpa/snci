<cfprocessingdirective pageencoding = "utf-8">
<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
  <cfquery name="rsSE" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT Dir_Codigo, Dir_Sigla FROM Diretoria WHERE Dir_Codigo<>'01'
  </cfquery>
</cfif>


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

   <cfset links = [
        { href = "index.cfm", icon = "fas fa-home", text = "Principal" },
        { href = "aa_deficiencias_controle.cfm", icon = "fas fa-bug", text = "Deficiências de Controle" },
        { href = "teste.cfm", icon = "fas fa-shield-alt", text = "Vulnerabilidades" },
        { href = "teste.cfm", icon = "fas fa-tasks", text = "Testes Aplicados" },
        { href = "relatorios.cfm", icon = "fas fa-database", text = "Base de Eventos" },
        { href = "orientacoes.cfm", icon = "fas fa-info-circle", text = "Orientações" },
        { href = "historicoAnual.cfm", icon = "fas fa-history", text = "Histórico Anual" }
      ] />


    


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
        background: none;
        border-radius: 15px;
        margin: 15px;
        padding: 5px;
        text-align: center;
        backdrop-filter: blur(5px);
        border: 1px solid rgba(255, 255, 255, 0.2);
      }

      .modern-nav-header h3 {
        color: rgba(255, 255, 255, 0.9) !important;
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
        font-size: 0.8rem;
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

      .nav-pills .nav-link {
          border-radius: .7rem;
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
      <aside class="main-sidebar sidebar-dark-primary elevation-4 modern-sidebar" style="margin-top: 0;">
        <!-- Sidebar -->
        <div class="sidebar os-host os-theme-light os-host-overflow os-host-resize-disabled os-host-transition os-host-overflow-y os-host-scrollbar-horizontal-hidden" style="margin-top: 0;" >
         
          <!-- Header do Sidebar -->
          <div class="modern-nav-header">
            <h3>Páginas</h3>
            <!--<small style="color: rgba(255, 255, 255, 0.8); font-size: 0.85rem;">Sistema Nacional de Controle Interno</small>-->
          </div>

          <!---Se servidor não for de produção, aparecerá o select para alteração de perfil e lotação --->
          <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
            <div class="modern-profile-section">
              <div class="form-group" style="margin-bottom: 0;">
                <select id="mudarSE" name="mudarSE" class="form-control" style="height:40px;">
                  <option selected="" disabled="" value="">Selecionar SE</option>
                  <cfoutput query="rsSE">
                    <option value="#Dir_Codigo#">#Dir_Sigla#</option>
                  </cfoutput>
                </select> 

                <select id="mudarUnidade" name="mudarUnidade" class="form-control" style="height:40px;" disabled>
                  <option value="">Primeiro selecione uma SE</option>
                </select>   
              </div>
            </div>
          </cfif>

          <nav class="mt-3">
            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false" style="list-style: none; padding: 0;">
              
             <cfloop array="#links#" index="link">
              <cfoutput>
                <li class="nav-item" style="margin-bottom: 0;">
                  <a href="#link.href#" class="nav-link modern-nav-link">
                    <div class="modern-nav-icon">
                      <i class="#link.icon#"></i>
                    </div>
                    <span class="modern-nav-text">#link.text#</span>
                  </a>
                </li>
              </cfoutput>
            </cfloop>


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
        
        // Inicializar Select2 apenas uma vez
        $('#mudarSE').select2({
          theme: 'bootstrap4'
        });
        
        $('#mudarUnidade').select2({
          theme: 'bootstrap4'
        });
        
        // Filtro dinâmico entre SE e Unidade
        $('#mudarSE').change(function() {
          var selectedSE = $(this).val();
          var unidadeSelect = $('#mudarUnidade');
          
          if (selectedSE) {
            // Desabilitar select e mostrar loading
            unidadeSelect.prop('disabled', true);
            
            // Limpar opções e adicionar loading
            unidadeSelect.empty();
            unidadeSelect.append('<option value="">Carregando...</option>');
            unidadeSelect.trigger('change');
            
            // Fazer requisição AJAX
            $.ajax({
              url: '../SNCI_AVALIACOES_AUTOMATIZADAS/cfc/DeficienciasControleDados.cfc',
              type: 'POST',
              data: {
                method: 'getUnidadesPorSE',
                codDiretoria: selectedSE
              },
              dataType: 'json',
              success: function(response) {
                // Limpar select
                unidadeSelect.empty();
                
                if (response.success && response.data.length > 0) {
                  // Adicionar opção padrão
                  unidadeSelect.append('<option value="">Selecionar Unidade</option>');
                  
                  // Adicionar unidades
                  $.each(response.data, function(index, unidade) {
                    unidadeSelect.append('<option value="' + unidade.codigo + '">' + unidade.nome + '</option>');
                  });
                } else {
                  unidadeSelect.append('<option value="">Nenhuma unidade encontrada</option>');
                }
                
                // Habilitar select e atualizar
                unidadeSelect.prop('disabled', false);
                unidadeSelect.trigger('change');
              },
              error: function(xhr, status, error) {
                console.error('Erro na requisição AJAX:', error);
                unidadeSelect.empty();
                unidadeSelect.append('<option value="">Erro ao carregar unidades</option>');
                unidadeSelect.prop('disabled', true);
                unidadeSelect.trigger('change');
              }
            });
          } else {
            // Se nenhuma SE selecionada, resetar unidades
            unidadeSelect.empty();
            unidadeSelect.append('<option value="">Primeiro selecione uma SE</option>');
            unidadeSelect.prop('disabled', true);
            unidadeSelect.trigger('change');
          }
        });
        
        // Event listener para mudança de unidade
        $('#mudarUnidade').change(function() {
          var selectedUnidade = $(this).val();
          var selectedUnidadeText = $(this).find('option:selected').text();
          
          if (selectedUnidade) {
            console.log('Unidade selecionada:', selectedUnidade);
            
            // Mostrar loading
            $(this).prop('disabled', true);
            
            // Atualizar lotação do usuário
            $.ajax({
              url: '../SNCI_AVALIACOES_AUTOMATIZADAS/cfc/DeficienciasControleDados.cfc',
              type: 'POST',
              data: {
                method: 'atualizarLotacaoUsuario',
                codigoUnidade: selectedUnidade,
                nomeUnidade: selectedUnidadeText,
                matriculaUsuario: '<cfoutput>#application.rsUsuarioParametros.Usu_Matricula#</cfoutput>'
              },
              dataType: 'json',
              success: function(response) {
                if (response.success) {
                  // Mostrar mensagem de sucesso
                  toastr.options = {
                      "positionClass": "toast-top-center"
                  };
                      toastr.success('Lotação atualizada com sucesso!');
                  
                  // Recarregar a página após um breve delay
                  setTimeout(function() {
                    window.location.reload();
                  }, 1500);
                } else {
                  console.error('Erro:', response.message);
                  toastr.error('Erro ao atualizar lotação: ' + response.message);
                  $(this).prop('disabled', false);
                }
              },
              error: function(xhr, status, error) {
                console.error('Erro na requisição AJAX:', error);
                toastr.error('Erro ao atualizar lotação');
                $(this).prop('disabled', false);
              }
            });
          }
        });
        
      });
		
  </script>

    
	
  </body>
</html>