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
	
        
		<cfinclude template="includes/pc_navBar.cfm">

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2" >
                        <div class="col-sm-6">
                            <h3>Cadastrar Faq , Guias & Turoriais</h3>
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
   


        <cfinclude template="includes/pc_footer.cfm">
    </div>

	    <cfinclude template="includes/pc_sidebar.cfm">
   
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

        // Adicionando a função que está faltando
        function mostraFormEditFaq(faqId, tit) {
            event.preventDefault();
            event.stopPropagation();
            var titulo = decodeURIComponent(tit);

            $('#modalOverlay').modal('show');
            setTimeout(function() {
                $.ajax({
                    type: "post",
                    url: "cfc/pc_cfcFaqs.cfc",
                    data: {
                        method: "formCadFaq",
                        pc_faq_id: faqId
                    },
                    async: false
                })//fim ajax
                .done(function(result) {
                    $('#formCadFaqDiv').html(result);
                    $('#faqTitulo').val(titulo);
                    $('#cabecalhoAccordion').text("Editar a informação ID " + faqId + ': ' + titulo);
                    $("#btSalvarDiv").attr("hidden", false);
                    $("#faqStatusDiv").show();
                    
                    // Nova verificação com delay: se faqTexto for vazio ou "null", ativa envio de arquivo
                    if (!$('#faqTexto').val() || $('#faqTexto').val().trim() === "" || $('#faqTexto').val().trim().toLowerCase() === "null") {
                        setTimeout(function(){
                            $('input[name="envioFaq"][value="arquivo"]').prop("checked", true).trigger("change");
                            // Exibe o nome do arquivo anexo, se disponível
                            var anexoNome = $('#faqAnexoNome').val();
                            if(anexoNome && anexoNome.trim() !== ""){
                                if (typeof setArquivoFaqDiv === 'function') {
                                    setArquivoFaqDiv();
                                }
                            }
                        }, 100);
                    }

                    $('#cadastroFaq').CardWidget('expand');
                    $('html, body').animate({ scrollTop: ($('#formCadFaqDiv').offset().top-80) }, 1000);
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                })//fim done
                .fail(function(xhr, ajaxOptions, thrownError) {
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                    $('#modal-danger').modal('show');
                    $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
                    $('#modal-danger').find('.modal-body').text(thrownError);
                });//fim fail
            }, 500);
        }

        // Adicionando função para manipular exclusão de FAQ, que também pode ser necessária
        function excluirFaq(faqId) {
            event.preventDefault();
            event.stopPropagation();
            var mensagem = "Deseja excluir este FAQ?";
            swalWithBootstrapButtons.fire({//sweetalert2
                html: logoSNCIsweetalert2(mensagem),
                showCancelButton: true,
                confirmButtonText: 'Sim!',
                cancelButtonText: 'Cancelar!'
            }).then((result) => {
                if (result.isConfirmed) {
                    $('#modalOverlay').modal('show');
                    setTimeout(function() {
                        $.ajax({
                            type: "GET",
                            url: "cfc/pc_cfcFaqs.cfc",
                            data: {
                                method: "delFaq",
                                pc_faq_id: faqId
                            },
                            async: false
                        })//fim ajax
                        .done(function(result) {
                            // Remove o ID do FAQ do localStorage
                            let readFaqs = JSON.parse(localStorage.getItem('readFaqs') || '[]');
                            readFaqs = readFaqs.filter(id => id !== faqId.toString());
                            localStorage.setItem('readFaqs', JSON.stringify(readFaqs));
                            
                            mostraFormCadFaq();
                            mostraTabFaq();
                            $('#modalOverlay').delay(1000).hide(0, function() {
                                $('#modalOverlay').modal('hide');
                                toastr.success('Operação realizada com sucesso!');
                            });
                        })//fim done
                        .fail(function(xhr, ajaxOptions, thrownError) {
                            $('#modalOverlay').delay(1000).hide(0, function() {
                                $('#modalOverlay').modal('hide');
                                var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
                                        + '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
                                const erroSistema = { html: logoSNCIsweetalert2(mensagem) };
                                swalWithBootstrapButtons.fire({...erroSistema});
                            });
                        })//fim fail
                    }, 500);
                }
            });
        }
        
    </script>
			

</body>

</html>
