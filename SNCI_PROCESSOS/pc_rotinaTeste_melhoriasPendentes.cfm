<cfprocessingdirective pageencoding = "utf-8">	
<cfsetting RequestTimeout = "0"> 

<cfquery name="rsOrgaosComMelhoriasPendentes" datasource="#application.dsn_processos#" >
    SELECT DISTINCT pc_aval_melhoria_num_orgao
    FROM pc_avaliacao_melhorias
    WHERE pc_aval_melhoria_status = 'P'	
</cfquery>


<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#" >
    SELECT pc_aval_melhoria_num_orgao
    FROM pc_avaliacao_melhorias
    WHERE pc_aval_melhoria_status = 'P'	
</cfquery>


<cfquery name="rsOrgaosComMelhoriasPendentesParaTeste" datasource="#application.dsn_processos#" >
    SELECT DISTINCT TOP 5 pc_aval_melhoria_num_orgao
    FROM pc_avaliacao_melhorias
    WHERE pc_aval_melhoria_status = 'P'	
</cfquery>


<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

  
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
                            <h4>Rotina de Verificação de Propostas de Melhoria Pendentes</h4>
                        </div>
                    </div>
                  
                    <h6 style="margin-top:30px">Quant. Órgãos com Propostas de Melhoria Pendentes: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComMelhoriasPendentes.recordcount,"00")#</cfoutput></span></h6>
                    <h6>Total de Propostas de Melhoria Pendentes: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#rsMelhoriasPendentes.recordcount#</cfoutput></span></h6>

                    <cfset quantPendentes = 0>
                    <cfif rsOrgaosComMelhoriasPendentesParaTeste.recordcount gt 0>
                        <cfif application.auxsite neq 'intranetsistemaspe'>
                            <cfset myQuery = "rsOrgaosComMelhoriasPendentesParaTeste">
                            <h6>Quant. Órgãos com Propostas de Melhoria pendentes para teste de envio de e-mail: <span style="background: #0083ca;color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComMelhoriasPendentesParaTeste.recordcount,"00")#</cfoutput></span></h6>

                        <cfelse>
                            <cfset myQuery = "rsOrgaosComMelhoriasPendentes">
                        </cfif>
                        <div style="margin-bottom:30px;justify-content:center; display: flex; width: 100%;margin-top:20px">
                            <div>
                                <button id="btnRotinaMelhoriasPendentes" class="btn btn-block btn-primary " >Executar Rotina</button>
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
        //cria click em um botão para um ajax para executar cffunction metodo rotinaMensalMelhoriasPendentes em pc_cfcPaginasApoio.cfc
        $(document).ready(function(){
            $("#btnRotinaMelhoriasPendentes").click(function(){
                Swal.fire({
                    html: logoSNCIsweetalert2('Deseja executar a rotina de verificação das Propostas de Melhoria Pendentes?<br>Esta rotina irá verificar as Propostas de Melhoria pendentes e enviará um e-mail de aviso para você como se fosse o órgão responsável.'), 
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
                                    method: "rotinaMensalMelhoriasPendentes",
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

                           

