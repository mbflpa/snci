<cfprocessingdirective pageencoding = "utf-8">	



<cfquery name="rsOrgaosComOrientacoesPendentes" datasource="#application.dsn_processos#" >
    SELECT DISTINCT pc_aval_orientacao_mcu_orgaoResp
    FROM pc_avaliacao_orientacoes
    WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
</cfquery>

<cfquery name="rsOrientacoesPendentes" datasource="#application.dsn_processos#" >
    SELECT pc_aval_orientacao_mcu_orgaoResp
    FROM pc_avaliacao_orientacoes
    WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
</cfquery>



<cfquery name="rsOrgaosComOrientacoesPendentesParaTeste" datasource="#application.dsn_processos#">
    SELECT DISTINCT TOP 30 pc_aval_orientacao_mcu_orgaoResp
    FROM pc_avaliacao_orientacoes
    WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
</cfquery>


<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        
        .table-striped tbody tr:nth-of-type(odd) {
            background-color: rgba(0,0,0,.05);
        }

        .text-nowrap {
            white-space: nowrap !important;
        }
        .table-bordered {
            border: 1px solid #dee2e6;
        }
       
      
        *, *::before, *::after {
            box-sizing: border-box;
        }

        table {
            width: 100%;
            margin-bottom: 1rem;
            color: #212529;
            background-color: transparent;
            display: table;
            border-collapse: separate;
            box-sizing: border-box;
            text-indent: initial;
            border-spacing: 2px;
            border-color: gray;
        }
        .card-body {
            text-align: justify!important;
        }
        .card {
            position: relative;
            display: -ms-flexbox;
            display: flex;
            -ms-flex-direction: column;
            flex-direction: column;
            min-width: 0;
            word-wrap: break-word;
            background-color: #fff;
            background-clip: border-box;
            border: 0 solid rgba(0, 0, 0, 0.125);
            border-radius: 0.25rem;
        }
        .card {
            position: relative;
            display: -ms-flexbox;
            display: flex;
            -ms-flex-direction: column;
            flex-direction: column;
            min-width: 0;
            word-wrap: break-word;
            background-color: #fff;
            background-clip: border-box;
            border: 0 solid rgba(0, 0, 0, 0.125);
            border-radius: 0.25rem;
        }
        body {
           
            font-family: "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            font-size: 0.8rem;
            font-weight: 400;
            line-height: 1.5;
            color: #212529;
            text-align: left;
            background-color: #fff;
        }
        th {
            text-align: center;
            padding-left: 0.75rem;
            padding-right: 0.75rem;

        }
        tr {
           text-align: center;
        }


       
    </style>
</head>
<body class="layout-footer-fixed hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">

    <div class="wrapper">
        <cfinclude template="pc_Modal_preloader.cfm">
        <cfinclude template="pc_NavBar.cfm">

    <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">

           
             <!-- Content Header (Page header) -->
            <section class="content-header">

                <div class="container-fluid" style="margin-bottom:80px;">
                    <div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
                        <div class="col-sm-6">
                            <h4>Rotina de Verificação de Orientações Pendentes</h4>
                        </div>
                    </div>
                  
                    <h6 style="margin-top:30px">Quant. Órgãos com Orientações Pendentes: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComOrientacoesPendentes.recordcount,"00")#</cfoutput></span></h6>
                    <h6>Total de Orientações Pendentes: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#rsOrientacoesPendentes.recordcount#</cfoutput></span></h6>

                    <cfset quantPendentes = 0>
                    <cfif rsOrgaosComOrientacoesPendentesParaTeste.recordcount gt 0>
                        <cfif FindNoCase("intranetsistemaspe", application.auxsite)>
                            <cfset myQuery = "rsOrgaosComOrientacoesPendentes">
                        <cfelse>
                            <cfset myQuery = "rsOrgaosComOrientacoesPendentesParaTeste">
                            <h6>Quant. Órgãos com Orientações pendentes para envio de e-mail: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComOrientacoesPendentesParaTeste.recordcount,"00")#</cfoutput></span></h6>

                        </cfif>
                        <div style="margin-bottom:30px;justify-content:center; display: flex; width: 100%;margin-top:20px">
                            <div>
                                <button id="btnRotinaOrientacoesPendentes" class="btn btn-block btn-primary " >Executar Rotina</button>
                            </div>      
                        </div>
                       
                    </cfif>
                   
                    
                </div>
            </section>
        </div>
    </div>
    <!-- Footer -->
    <cfinclude template="pc_Footer.cfm">   

    <cfinclude template="pc_Sidebar.cfm">
     <script language="JavaScript">
        //cria click em um botão para um ajax para executar cffunction metodo rotinaSemanalOrientacoesPendentes em pc_cfcPaginasApoio.cfc
        $(document).ready(function(){
            $("#btnRotinaOrientacoesPendentes").click(function(){
                var mensagem = '';
                <cfoutput >
                    var emailUsuario = '#application.rsUsuarioParametros.pc_usu_email#';
                    <cfif FindNoCase("intranetsistemaspe", application.auxsite)>
                        mensagem = 'Deseja executar a rotina de verificação das Orientações Pendentes?<br>Esta rotina irá verificar as orientações pendentes e enviará um e-mail de aviso o órgão responsável.';
                    <cfelse>
                        //verifica se o usuário possui e-mail cadastrado
                        <cfif application.rsUsuarioParametros.pc_usu_email eq ''>
                            mensagem = '<p style="text-align: justify;">Não foi possível executar a rotina de verificação das Propostas de Melhoria Pendentes.<br><br>Seu e-mail não está cadastrado no SNCI-Processos.<br><br>Informe o administrador do sistema para que ele possa cadastrar seu e-mail.</p>';
                            //exibe mensagem de erro
                            Swal.fire({
                                html: logoSNCIsweetalert2(mensagem), 
                                title: '',
                                confirmButtonText: 'OK!',
                            })
                            //sai da função
                            return false;
                        </cfif>
                        mensagem = 'Deseja executar a rotina de verificação das Orientações Pendentes?<br>Esta rotina irá verificar as orientações pendentes e enviará um e-mail de aviso para você como se fosse o órgão responsável.<br><br>ATENÇÃO: Esta rotina não irá enviar e-mail para os órgãos, apenas para você:<br>' + emailUsuario + '.';
                    </cfif>
                </cfoutput>
                Swal.fire({
                    html: logoSNCIsweetalert2(mensagem), 
                    title: '',
                    showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
                }).then((result) => {
                    if (result.isConfirmed) {
                        $('#modalOverlay').modal('show')
                        setTimeout(function() {
                            $.ajax({
                                type: "post",
                                url: "cfc/pc_cfcPaginasApoio.cfc",
                                data:{
                                    method: "rotinaSemanalOrientacoesPendentesSemTab",
                                },
                                async: false,
                                success: function(result) {
                                    $('#modalOverlay').delay(1000).hide(0, function() {
                                        $('#modalOverlay').modal('hide');
                                        Swal.fire({
                                            html: logoSNCIsweetalert2('Rotina executada com sucesso!'),
                                            title: '',
                                            confirmButtonText: 'OK!',
                                        })
                                    });
                                },
                                error: function(xhr, ajaxOptions, thrownError) {
                                    $('#modalOverlay').delay(1000).hide(0, function() {
                                        $('#modalOverlay').modal('hide');
                                    });
                                    $('#modal-danger').modal('show')
                                    $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
                                    $('#modal-danger').find('.modal-body').text(thrownError)
                                }
                            });
                        }, 500);
                    }
                })



            });
        });
        

    </script>	


</body>
</html>

                           

