<cfprocessingdirective pageencoding = "utf-8">



<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">

</head>

<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
<!-- Site wrapper -->
    <div class="wrapper">
	


        
		<cfinclude template="pc_NavBar.cfm">

 

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <cfquery name="qTiposFaq" datasource="#application.dsn_processos#">
                        SELECT pc_faq_tipo_id, pc_faq_tipo_nome, pc_faq_tipo_cor from pc_faq_tipos WHERE pc_faq_tipo_status ='A' ORDER BY pc_faq_tipo_id
                    </cfquery>

                    <div class="row mb-2" >
                        <div class="col-sm-6">
                            <h1>Guias & Tutoriais</h1>
                            <div class="faq-legend" style="margin-top: 10px; font-size: 14px; display: flex; gap: 20px;">
                                <!-- Legenda "Todos" -->
                                <div class="card card-outline faq-card" data-tipo="0" style="border-top: 3px solid #000; padding: 0;cursor:pointer;">
                                    <div class="card-body" style="padding:2px 8px!important;">
                                        Todos
                                    </div>
                                </div>
                                <cfoutput query="qTiposFaq">
                                    <div class="card card-outline faq-card" data-tipo="#pc_faq_tipo_id#" style="border-top: 3px solid #pc_faq_tipo_cor#; padding: 0;cursor:pointer;">
                                        <div class="card-body" style="padding:2px 8px!important;">
                                            #pc_faq_tipo_nome#
                                        </div>
                                    </div>
                                </cfoutput>
                            </div>
                            <!-- Novo span para indicar o filtro aplicado -->
                            <div style="display:flex; ">
                                <span style="display:block; margin-top:5px; font-size:14px;">Filtro Atual:</span><span id="filterIndicator" style="display:block; margin-top:5px; margin-left:5px; font-weight:bold; font-size:14px;">Todos</span>
                           </div>
                        </div>
                    </div>
                </div><!-- /.container-fluid -->
            </section>

            <style>
            .card-title{
                font-size: 20px;
            }
            .card-body{
                font-size: 16px;
            }
            </style>

           

            <section class="content" >
                <div class="container-fluid">
                    <div id="formFaqDiv" style="padding-bottom:80px"></div>
                </div>
            </section>
           

        </div>
        <!-- /.content-wrapper -->
   


        <cfinclude template="pc_Footer.cfm">
    </div>

	    <cfinclude template="pc_Sidebar.cfm">

    <script language="JavaScript">

        
        $(document).ready(function() {	
            mostraFormFaq(); // Carrega todos os FAQs por padrão
            $('.faq-card').on('click', function(){
                var tipo = $(this).data('tipo');
                // Atualiza o indicador de filtro com o texto do card clicado
                var filtroTexto = $(this).find('.card-body').text().trim();
                $('#filterIndicator').text(filtroTexto);
                filtraFaq(tipo);
            });
        });   

        function mostraFormFaq(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcFaqs.cfc",
                data: {
                    method: "formFaq",
                    tipoFaq: 0
                },
                dataType: "text"  // Mantido em "text" para lidar tanto com JSON quanto HTML
            })
            .done(function(response) {
                if(!response || response.trim() === ""){
                    $('#formFaqDiv').html("<p>Nenhum FAQ retornado pelo servidor.</p>");
                    return;
                }
                var result;
                try {
                    result = JSON.parse(response);
                } catch(e) {
                    result = { type: "text", content: response };
                }

                html = result.content;
                
                $('#formFaqDiv').html(html);
            })
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                });
                $('#modal-danger').modal('show');
                $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
                $('#modal-danger').find('.modal-body').text(thrownError);
            });
        }

        function filtraFaq(tipoFaq){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcFaqs.cfc",
                data: { method: "formFaq", tipoFaq: tipoFaq },
                dataType: "text"
            })
            .done(function(response) {
                if(!response || response.trim() === ""){
                    $('#formFaqDiv').html("<p>Nenhum FAQ retornado pelo servidor.</p>");
                    return;
                }
                var result;
                try {
                    result = JSON.parse(response);
                } catch(e) {
                    result = { type: "text", content: response };
                }

                html = result.content;
                
                $('#formFaqDiv').html(html);
            })
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                });
                $('#modal-danger').modal('show');
                $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
                $('#modal-danger').find('.modal-body').text(thrownError);
            });
        }

        
    </script>
			

</body>

</html>
