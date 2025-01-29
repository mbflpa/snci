<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultar Processos Sem Pesquisa</title>
    <style>
        .card-body {
            text-align: justify!important;
        }
        .popover-body {
            text-align: justify!important;
        }
        .swal2-label {
            text-align: justify;
        }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <cfinclude template="pc_NavBar.cfm">

        <div class="content-wrapper">
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2" style="margin-bottom:0px!important;">
                        <div class="col-sm-12">
                            <div style="display: flex; align-items: center;">
                                <h4 style="margin-right: 10px;">Consultar Processos c/ Pesquisas não Respondidas</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="content">
                <div class="container-fluid">
                    <div id="exibirTabSpinner"></div>
                    <div id="exibirTab"></div>
                </div>
            </section>
        </div>

        <cfinclude template="pc_Footer.cfm">
    </div>

    <cfinclude template="pc_Sidebar.cfm">

   
    <script language="JavaScript">
        $(document).ready(function () {
            $("#modalOverlay").modal("show");

            exibirTabela();

            function exibirTabela() {
                $("#modalOverlay").modal("show");
                //$('#exibirTab').hide();
                //$("#exibirTab").html('');
                $("#exibirTabSpinner").html('<h1 style="margin-left:50px;color:#e83e8c"><i class="fas fa-spinner fa-spin"></i><span style="font-size:20px"> Carregando dados, aguarde...</span></h1>');
                setTimeout(function () {
                    $.ajax({
                        type: "post",
                        url: "cfc/pc_cfcConsultasProcessosSemPesquisa.cfc",
                        data: {
                            method: "obterProcessosSemPesquisa"
                        },
                        async: false,
                        success: function (result) {
                            $("#exibirTab").html(result);
                            $("#exibirTabSpinner").html("");
                            $("#modalOverlay").delay(1000).hide(0, function () {
                                $("#modalOverlay").modal("hide");
                            });
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            $("#modalOverlay").delay(1000).hide(0, function () {
                                $("#modalOverlay").modal("hide");
                            });
                            $("#modal-danger").modal("show");
                            $("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
                            $("#modal-danger").find(".modal-body").text(thrownError);
                        },
                    });
                }, 500);
            }
        });
    </script>
</body>
</html>
