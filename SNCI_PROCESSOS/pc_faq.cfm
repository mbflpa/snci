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
                    

                    <div class="row mb-2" >
                        <div class="col-sm-6">
                            <h1>FAQ <span style="font-size:14px">(perguntas frequentes)</span></h1>
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
                
            mostraFormFaq()
            
        });   

        function mostraFormFaq(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcFaqs.cfc",
                data: {
                    method: "formFaq"
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

        
    </script>
			

</body>

</html>
