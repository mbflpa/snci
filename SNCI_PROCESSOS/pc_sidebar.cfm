
<cfprocessingdirective pageencoding = "utf-8">


<cfif Not ListContains(application.Lista_usuariosCad,UCase(application.rsUsuarioParametros.pc_usu_login))>
  <cflocation url = "sem_acesso_sistema.html" addToken = "no">
</cfif>  
<!--cgi.script_name retorna a página atual e verifica na tabela pc_controle_acesso se u perfil do usuario atual tem acesso a essa página -->
<cfif NOT ListContains(UCase(application.Lista_paginasPerfilUsuario),UCase(cgi.script_name)) and UCase(cgi.script_name) neq '/snci/snci_processos/index.cfm'>
  <cflocation url = "sem_acesso_pagina.html?pagina=#cgi.script_name#" addToken = "no">
</cfif> 
 


  <!--- Consulta Permissões --->
	<cfquery name="qPermissões" datasource="#application.dsn_processos#">
	  	SELECT DISTINCT pc_perfil_tipo_id, pc_perfil_tipo_descricao
      FROM   pc_perfil_tipos
      where  pc_perfil_tipo_status = 'A'
      ORDER BY pc_perfil_tipo_descricao
	</cfquery>

  <cfquery name="qAreas" datasource="#application.dsn_processos#">
    SELECT pc_org_mcu, pc_org_sigla
    FROM pc_orgaos
    WHERE  (pc_org_Status in ('A', 'O'))
    ORDER BY pc_org_sigla
  </cfquery>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">

  
	<!-- Font Awesome -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/fontawesome.min.css">
	<!-- Tempusdominus Bootstrap 4 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
	<!-- iCheck -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
	
	<!-- overlayScrollbars -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
	<!-- Daterange picker -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/daterangepicker/daterangepicker.css">

	<!-- SweetAlert2 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.css">
	<!-- Toastr -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/toastr/toastr.css">
	<!-- Bootstrap4 Duallistbox -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/bootstrap4-duallistbox/bootstrap-duallistbox.css">
	<!-- dropzonejs -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/dropzone/min/dropzone.min.css">
	<!-- DataTables -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-buttons/css/buttons.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-select/css/select.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-scroller/css/scroller.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-searchpanes/css/searchPanes.bootstrap4.min.css">
	
	
	<!-- Select2 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/select2/css/select2.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">
 

	

	<!-- Tour -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/tour/dist/css/hopscotch.css">

  <!-- Theme style -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/adminlte.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/stylesSNCI.css">


    <style>
          .select2-container--bootstrap4 .select2-dropdown .select2-results__option[aria-selected="true"] {
            color: #fff!important;
            background-color: #00416b!important;
          }
          .select2-results__option{
            font-size:11px!important;
          }
        
    </style>
</head>
<body>


      <!-- Main Sidebar Container -->
      <aside class="main-sidebar sidebar-dark-primary elevation-4" style="overflow:hidden!important;">
        <!-- Brand Logo -->
      
          <a href="../SNCI_PROCESSOS/index.cfm" class="brand-link" style="background-color:#f4f6f9;height: auto;" >
            <img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png" class="brand-image" style="position:relative;left:-5px;top:2px">
            <span class="brand-text font-weight-light" style="font-size:20px!important;color:#00416B">SNCI - Processos</span>
          </a>
  
        <!-- Sidebar -->
        <div class="sidebar os-host os-theme-light os-host-overflow os-host-resize-disabled os-host-transition os-host-overflow-y os-host-scrollbar-horizontal-hidden" style="background-color:#00416B;">
          <!-- Sidebar user panel (optional) -->
          <a href="../SNCI_PROCESSOS/index.cfm" class="user-panel brand-link user-panel" style="height: auto; display: flex; align-items: center;">
            <img src="../SNCI_PROCESSOS/dist/img/avatardefault.png" class="img-circle elevation-2" alt="User Image" style="width: 3rem;">
            <span class="brand-text font-weight-light" style="font-size: 10px !important; word-wrap: break-word; max-width: calc(100% - 3rem - 10px);"> <!-- Ajuste o valor 10px conforme necessário para o espaçamento -->
              <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#<br>#application.rsUsuarioParametros.pc_usu_login# <br> #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>
            </span>
          </a>
          <!---verifica de qual servidor a rotina está sendo disparada--->
          <cfset servidor =  cgi.server_name>
          <!---Se servidor não for de produção, aparecerá o select para alteração de perfil e lotação --->
          <cfif '#servidor#' neq "intranetsistemaspe" or #application.rsUsuarioParametros.pc_usu_matricula# eq '80859992'>
            <div style="font-size:10px !important;">
              <div class="form-group" style="width:auto;margin-top:10px;index-z:1000;position:relative">
                <select id="mudarPerfil" name="mudarPerfil" class="form-control" style="height:35px;">
                  <option selected="" disabled="" value="">Altere seu perfil...</option>
                  <cfoutput query="qPermissões" >
                    <option value="#pc_perfil_tipo_id#">#pc_perfil_tipo_id# - #pc_perfil_tipo_descricao#</option>
                  </cfoutput>
                </select> 

                <select id="mudarLotacao" name="mudarLotacao" class="form-control" style="height:35px;">
                  <option selected="" disabled="" value="">Altere sua lotação...</option>
                  <cfoutput query="qAreas" >
                    <option value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
                  </cfoutput>
                </select>   
              </div>
            </div>
          </cfif>

          <cfquery datasource="#application.dsn_processos#" name="rsControleAcesso">
	          SELECT pc_controle_acesso.* FROM   pc_controle_acesso
            where pc_controle_acesso_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%'
            ORDER BY pc_controle_acesso_grupoMenu, pc_controle_acesso_subgrupoMenu, pc_controle_acesso_ordem 
          </cfquery>

          <nav class="mt-2" >
            <ul class="nav nav-pills nav-sidebar flex-column nav-child-indent " data-widget="treeview" role="menu" data-accordion="false">
         
              <cfoutput query = "rsControleAcesso" group = "pc_controle_acesso_grupoMenu" groupCaseSensitive = "no" >
                <cfif '#pc_controle_acesso_grupoMenu#' neq '' >
                  <cfset id1 = REReplace(pc_controle_acesso_grupoMenu, "[\(\)\s]+", "", "ALL")>
                  <cfset id1 = ReplaceNoCase(id1, "ç", "c", "ALL")>
                  <cfset id1 = REReplace(id1, "[áàâã]", "a", "ALL")>
                  <cfset id1 = REReplace(id1, "[éèê]", "e", "ALL")>
                  <cfset id1 = REReplace(id1, "[íìî]", "i", "ALL")>
                  <cfset id1 = REReplace(id1, "[óòôõ]", "o", "ALL")>
                  <cfset id1 = REReplace(id1, "[úùû]", "u", "ALL")>
                  <li id="#id1#" class="nav-item ">
                    <a href="../SNCI_PROCESSOS/##" class="nav-link ">
                      <i class="nav-icon fas #pc_controle_acesso_grupo_icone#"></i>
                      <p >
                        #pc_controle_acesso_grupoMenu#
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" >
                      <cfoutput>
                        <cfif #pc_controle_acesso_subgrupoMenu# eq '' and ListContains(pc_controle_acesso_perfis,application.rsUsuarioParametros.pc_usu_perfil)>
                          <cfset id2 = REReplace(pc_controle_acesso_nomeMenu, "[\(\)\s]+", "", "ALL")>
                          <cfset id2 = ReplaceNoCase(id2, "ç", "c", "ALL")>
                          <cfset id2 = REReplace(id2, "[áàâã]", "a", "ALL")>
                          <cfset id2 = REReplace(id2, "[éèê]", "e", "ALL")>
                          <cfset id2 = REReplace(id2, "[íìî]", "i", "ALL")>
                          <cfset id2 = REReplace(id2, "[óòôõ]", "o", "ALL")>
                          <cfset id2 = REReplace(id2, "[úùû]", "u", "ALL")>
                          <li id="#id2#" class="nav-item">
                            <a href="../SNCI_PROCESSOS/./#pc_controle_acesso_pagina#" class="nav-link ">
                              <i class="<cfif #pc_controle_acesso_menu_icone# eq ''>far fa-circle nav-icon<cfelse>fas #pc_controle_acesso_menu_icone# nav-icon</cfif>"></i>
                              <p >#pc_controle_acesso_nomeMenu#</p>
                            </a>
                          </li>
                        </cfif>
                      </cfoutput>
                      <cfoutput group = "pc_controle_acesso_subgrupoMenu" >
                        <cfif '#pc_controle_acesso_subgrupoMenu#' neq '' >
                          <cfset id3 = REReplace(pc_controle_acesso_subgrupoMenu, "[\(\)\s]+", "", "ALL")>
                          <cfset id3 = ReplaceNoCase(id3, "ç", "c", "ALL")>
                          <cfset id3 = REReplace(id3, "[áàâã]", "a", "ALL")>
                          <cfset id3 = REReplace(id3, "[éèê]", "e", "ALL")>
                          <cfset id3 = REReplace(id3, "[íìî]", "i", "ALL")>
                          <cfset id3 = REReplace(id3, "[óòôõ]", "o", "ALL")>
                          <cfset id3 = REReplace(id3, "[úùû]", "u", "ALL")>
                          <li id="#id3#" class="nav-item">  
                              <a href="../SNCI_PROCESSOS/##" class="nav-link">
                                <i class="far <cfif #pc_controle_acesso_subgrupo_icone# eq ''>fa-circle <cfelse>fas #pc_controle_acesso_subgrupo_icone#</cfif> nav-icon"></i>
                                <p >
                                  #pc_controle_acesso_subgrupoMenu#
                                  <i class="right fas fa-angle-left"></i>
                                </p>
                              </a>
                          
                            <ul class="nav nav-treeview" >
                              <cfoutput>
                                <cfif ListContains(pc_controle_acesso_perfis,application.rsUsuarioParametros.pc_usu_perfil)>
                                    <cfset id4 = REReplace(pc_controle_acesso_nomeMenu, "[\(\)\s]+", "", "ALL")>
                                    <cfset id4 = ReplaceNoCase(id4, "ç", "c", "ALL")>
                                    <cfset id4 = REReplace(id4, "[áàâã]", "a", "ALL")>
                                    <cfset id4 = REReplace(id4, "[éèê]", "e", "ALL")>
                                    <cfset id4 = REReplace(id4, "[íìî]", "i", "ALL")>
                                    <cfset id4 = REReplace(id4, "[óòôõ]", "o", "ALL")>
                                    <cfset id4 = REReplace(id4, "[úùû]", "u", "ALL")>
                                    <li id="#id4#" class="nav-item">
                                      <a href="../SNCI_PROCESSOS/./#pc_controle_acesso_pagina#" class="nav-link">
                                        <i class=" <cfif #pc_controle_acesso_menu_icone# eq ''>far fa-circle<cfelse>fas #pc_controle_acesso_menu_icone#</cfif> nav-icon"></i>
                                        <p >#pc_controle_acesso_nomeMenu#</p>
                                      </a>
                                    </li>
                                </cfif>
                              </cfoutput>
                            </ul>
                          </li>
                        </cfif>
                      </cfoutput>
                    </ul>
                  </li>
                <cfelse>
                  <cfoutput group = "pc_controle_acesso_nomeMenu" >
                    <cfif ListContains(pc_controle_acesso_perfis,application.rsUsuarioParametros.pc_usu_perfil)>
                      <cfset id5 = REReplace(pc_controle_acesso_nomeMenu, "[\(\)\s]+", "", "ALL")>
                      <cfset id5 = ReplaceNoCase(id5, "ç", "c", "ALL")>
                      <cfset id5 = REReplace(id5, "[áàâã]", "a", "ALL")>
                      <cfset id5 = REReplace(id5, "[éèê]", "e", "ALL")>
                      <cfset id5 = REReplace(id5, "[íìî]", "i", "ALL")>
                      <cfset id5 = REReplace(id5, "[óòôõ]", "o", "ALL")>
                      <cfset id5 = REReplace(id5, "[úùû]", "u", "ALL")>
                      <li id="#id5#" class="nav-item">
                        <a href="../SNCI_PROCESSOS/./#pc_controle_acesso_pagina#" class="nav-link">
                          <i class="nav-icon fas <cfif #pc_controle_acesso_menu_icone# eq ''>fa-circle<cfelse>#pc_controle_acesso_menu_icone#</cfif>"></i>
                          <p >#pc_controle_acesso_nomeMenu#</p>
                        </a>
                      </li>
                    </cfif>
                  </cfoutput>


                </cfif>
              </cfoutput>
            </ul>
          </nav>
         
        </div>
        
      </aside>
  
    <!-- jQuery -->
		<script src="../SNCI_PROCESSOS/plugins/jquery/jquery.min.js"></script>

		<!-- Bootstrap 4 -->
		<script src="../SNCI_PROCESSOS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>

		<!-- jQuery UI 1.11.4 -->
		<script src="../SNCI_PROCESSOS/plugins/jquery-ui/jquery-ui.min.js"></script>
 
  
    
		<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
		<script language="JavaScript">
	    $.widget.bridge('uibutton', $.ui.button)
		</script>

    <!-- jspdf -->
		<script  src="../SNCI_PROCESSOS/plugins/jspdf/jspdf.min.js"></script>

   <!-- html2pdf-->
    <script  src="../SNCI_PROCESSOS/plugins/html2pdf/html2pdf.bundle.min.js"></script>

 		<!-- Sparkline -->
		<script  src="../SNCI_PROCESSOS/plugins/sparklines/sparkline.js"></script>

		<!-- daterangepicker -->
		<script  src="../SNCI_PROCESSOS/plugins/moment/moment.min.js"></script>
		<script  src="../SNCI_PROCESSOS/plugins/daterangepicker/daterangepicker.js"></script>

		<!-- Tempusdominus Bootstrap 4 -->
		<script  src="../SNCI_PROCESSOS/plugins/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"></script>

		<!-- overlayScrollbars -->
		<script  src="../SNCI_PROCESSOS/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>

		<!-- bs-custom-file-input -->
		<script  src="../SNCI_PROCESSOS/plugins/bs-custom-file-input/bs-custom-file-input.min.js"></script>

		<!-- Select2 -->
		<script  src="../SNCI_PROCESSOS/plugins/select2/js/select2.full.min.js"></script>

		<!-- InputMask -->
		<script  src="../SNCI_PROCESSOS/plugins/inputmask/jquery.inputmask.min.js"></script>

		<!-- dropzonejs -->
		<script  src="../SNCI_PROCESSOS/plugins/dropzone/min/dropzone.min.js"></script>

    
	
    <!-- jquery-validation -->
    <script  src="../SNCI_PROCESSOS/plugins/jquery-validation/jquery.validate.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/jquery-validation/additional-methods.min.js"></script>

    <!-- SweetAlert2 -->
    <script  src="../SNCI_PROCESSOS/plugins/sweetalert2/sweetalert2.min.js"></script>

    <!-- Toastr -->
    <script  src="../SNCI_PROCESSOS/plugins/toastr/toastr.min.js"></script>

    <!-- DataTables  & Plugins -->
    <script  src="../SNCI_PROCESSOS/plugins/datatables/jquery.dataTables.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-bs4/js/dataTables.bootstrap4.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-responsive/js/dataTables.responsive.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-fixedheader/js/dataTables.fixedHeader.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-fixedheader/js/fixedHeader.bootstrap4.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-rowreorder/js/dataTables.rowReorder.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-responsive/js/responsive.bootstrap4.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-buttons/js/dataTables.buttons.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-buttons/js/buttons.bootstrap4.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/jszip/jszip.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-buttons/js/buttons.html5.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-buttons/js/buttons.print.min.js"></script>
    <script  src="../SNCI_PROCESSOS/plugins/datatables-buttons/js/buttons.colVis.min.js"></script>	
    <script  src="../SNCI_PROCESSOS/plugins/datatables-select/js/dataTables.select.min.js"></script>	
    <script  src="../SNCI_PROCESSOS/plugins/datatables-searchpanes/js/dataTables.searchPanes.js"></script>	
    <script  src="../SNCI_PROCESSOS/plugins/datatables-searchpanes/js/searchPanes.bootstrap4.min.js"></script>	


    <!-- Tour -->
    <script  src="../SNCI_PROCESSOS/plugins/tour/dist/js/hopscotch.min.js"></script>

    
    <!-- SNCI -->
    <script src="../SNCI_PROCESSOS/dist/js/snciProcesso.js"></script>
  

    <!-- AdminLTE App -->
		<script  src="../SNCI_PROCESSOS/dist/js/adminlte.js"></script>
 


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
          logo= '<div style="position:absolute;top:5px;left:5px;whidth:100%;display:flex;justify-content: center;align-items: center;margin-bottom:10px"><img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png"class="brand-image" style="width:33px;margin-right:10px">'
              + '<span class="font-weight-light" style="font-size:20px!important;color:#00416B">SNCI - Processos</span></div>';

        }else{
          logo= '<div style="position:absolute;top:5px;left:5px;whidth:100%;display:flex;justify-content: center;align-items: center;margin-bottom:10px"><img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png"class="brand-image" style="width:33px;margin-right:10px">'
              + '<span class="font-weight-light" style="font-size:20px!important;color:#00416B">SNCI - Processos</span></div>'
              +'<div class="font-weight-light" style="color:#00416B;margin-top:20px">'+ mens + '</div>';

        }

        
            

        return logo;
      }

      //Initialize Select2 Elements
      $('select').select2({
        theme: 'bootstrap4'
      });

     //muda a permissão. Só ativo para os servers de desenvolvimento e homologação	
      
        $('#mudarPerfil').on('change', function (event)  {
            $('#modalOverlay').modal('show')
						setTimeout(function() {
              $.ajax({
                type: "GET",
                url: "cfc/pc_cfcProcessos.cfc",
                data:{
                  method: "mudarPerfil",
                  perfil:$('#mudarPerfil').val()
                },
                async: false,
                success: function(result) {
                  //window.location.reload(true);
                  window.location.href = "/snci/snci_processos/index.cfm";
                },
                error: function(xhr, ajaxOptions, thrownError) {
                  var erro = "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:\n"  + thrownError
                  alert(erro);
                }
              })	
            }, 500);
	
        

        });

        $('#mudarLotacao').on('change', function (event)  {
          $('#modalOverlay').modal('show')
					setTimeout(function() {
            $.ajax({
              type: "GET",
              url: "cfc/pc_cfcProcessos.cfc",
              data:{
                method: "mudarLotacao",
                lotacao:$('#mudarLotacao').val()
              },
              async: false,
              success: function(result) {
                //window.location.reload(true);
                 window.location.href = "/snci/snci_processos/index.cfm";  
              },
              error: function(xhr, ajaxOptions, thrownError) {
                var erro = "Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:\n"  + thrownError
                alert(erro);
              }
            })		
          }, 500);

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

      // Verifica se o link está dentro de um elemento com a classe 'nav-treeview'
      if (currentLink[0].closest(".nav-treeview")) {
        // Se sim, exibe esse elemento (caso estivesse oculto)
        currentLink[0].closest(".nav-treeview").style.display = "block";
      }

      // Verifica se o link está dentro de um elemento com a classe 'has-treeview'
      if (currentLink[0].closest(".has-treeview")) {
        // Se sim, adiciona a classe 'active' ao elemento para indicar que está ativo
        currentLink[0].closest(".has-treeview").classList.add("active");
      }
    } else {
      // Caso não encontre nenhum link correspondente na navegação, redireciona para uma página de acesso negado.
      if (url.pathname.toLowerCase() !== '/snci/snci_processos/index.cfm') {
        window.location.href = "sem_acesso_pagina.html?pagina=" + url.pathname;  
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
      //verifica se o órgão é subordinador
      <cfoutput>
        var subordinador = '#application.rsOrgaoSubordinados.recordcount#';
      </cfoutput>

      if (subordinador === '0') {//se não for subordinador, remove o menu de controle das distribuições
        // Encontre o elemento com id "ControledasDistribuicoes"
        var controledasDistribuicoesElement = document.getElementById("ControledasDistribuicoes");
        
        // Verifique se o elemento existe antes de tentar removê-lo
        if (controledasDistribuicoesElement) {
          // Remova o elemento
          controledasDistribuicoesElement.parentNode.removeChild(controledasDistribuicoesElement);
        }
      }

    });


		
  </script>

    
	
  </body>
</html>
