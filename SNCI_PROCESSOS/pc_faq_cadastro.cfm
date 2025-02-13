<cfprocessingdirective pageencoding = "utf-8">



<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
     <!-- CKeditor -->
    <script src="../SNCI_PROCESSOS/ckeditor/ckeditor.js"></script>
     
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
                            <h3>Cadastrar Guias & Tutoriais</h3>
                        </div>
                    </div>
                </div><!-- /.container-fluid -->
            </section>

            <!-- Main content -->
            <section class="content" style="margin-top: 0px!important">
                <div id="formCadFaqDiv" ></div>
            </section>

            <section class="content" >
                <div class="container-fluid">
                    <div id="tabFaqDiv" style="padding-bottom:80px"></div>
                </div>
            </section>
           

        </div>
        <!-- /.content-wrapper -->
   


        <cfinclude template="pc_Footer.cfm">
    </div>

	    <cfinclude template="pc_Sidebar.cfm">
   
    <script language="JavaScript">


        $(document).ready(function() {	
            $('#modalOverlay').modal('show')
            setTimeout(function() {
                mostraFormCadFaq()
                mostraTabFaq()
            }, 500);
        });

        function mostraFormCadFaq(){
        
                $.ajax({
                    type: "post",
                    url: "cfc/pc_cfcFaqs.cfc",
                    data:{
                        method: "formCadFaq"
                    },
                    async: true
                })//fim ajax
                .done(function(result) {
                    $('#formCadFaqDiv').html(result)
                    
                })//fim done
                .fail(function(xhr, ajaxOptions, thrownError) {
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                    $('#modal-danger').modal('show')
                    $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
                    $('#modal-danger').find('.modal-body').text(thrownError)

                })//fim fail
           
        }


        function mostraTabFaq(){
            $('#modalOverlay').modal('show')
			setTimeout(function() {
                $.ajax({
                    type: "post",
                    url: "cfc/pc_cfcFaqs.cfc",
                    data:{
                        method: "tabFaq"
                    },
                    async:false
                })//fim ajax
                .done(function(result) {
                    $('#tabFaqDiv').html(result)
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                })//fim done
                .fail(function(xhr, ajaxOptions, thrownError) {
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                    $('#modal-danger').modal('show')
                    $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
                    $('#modal-danger').find('.modal-body').text(thrownError)

                })//fim fail
            }, 500);
        }

        
    </script>
			

</body>

</html>
