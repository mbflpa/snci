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

<cfquery name="verificarExecucao" datasource="#application.dsn_processos#">
    SELECT pc_rotina_ultima_execucao 
    FROM pc_rotinas_execucao_emails_log 
    WHERE pc_rotina_nome = <cfqueryparam value="rotinaSemanal" cfsqltype="cf_sql_varchar">
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
        
        <cfinclude template="includes/pc_navBar.cfm">

    <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">

           
             <!-- Content Header (Page header) -->
            <section class="content-header">

                <div class="container-fluid" style="margin-bottom:80px;">
                    <div class="row mb-2" style="margin-bottom:0px!important;">
                        <div class="col-sm-12" >
                            <h4>Rotina de Verificação de Orientações Pendentes</h4>
                            
                                <div class="alert d-inline-flex align-items-center" style="background-color: #d52e44;border-color:#973450;color:#fff">
                                    <i class="fas fa-calendar-minus " style="font-size: 3rem;margin-right:20px"></i>
                                    <div>
                                        <cfset ultima_execucao = '#DateFormat(verificarExecucao.pc_rotina_ultima_execucao, "dd/mm/yyyy")# às #TimeFormat(verificarExecucao.pc_rotina_ultima_execucao, "HH:mm")#'>
                                        <cfif verificarExecucao.recordcount eq 0>
                                            <h5 class="mb-1">Última execução automática: <b>ainda não executada</b> (executada semanalmente)</h5>
                                        <cfelse>
                                            <h5 class="mb-1">Última execução automática: <b><cfoutput>#ultima_execucao#</cfoutput></b> (executada semanalmente)</h5>
                                        </cfif>
                                        <small>Obs.: Esta rotina é executada automaticamente sempre que um usuário do perfil CI - MASTER ACOMPANHAMENTO (Gestor Nível 4) entra no sistema.</small>
                                    </div>
                                </div>
                        </div>
                    </div>
                    <h6 style="margin-top:30px">SERVIDOR: <span class="azul_claro_correios_backgroundColor" style="color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#application.auxsite#</cfoutput></span></h6>
                    <h6 style="margin-top:30px">Quant. Órgãos com Orientações Pendentes: <span style="color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComOrientacoesPendentes.recordcount,"00")#</cfoutput></span></h6>
                    <h6>Total de Orientações Pendentes: <span class="azul_claro_correios_backgroundColor" style="color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#rsOrientacoesPendentes.recordcount#</cfoutput></span></h6>

                    <cfset quantPendentes = 0>
                    <cfif rsOrgaosComOrientacoesPendentesParaTeste.recordcount gt 0>
                        <cfif FindNoCase("intranetsistemaspe", application.auxsite)>
                            <cfset myQuery = "rsOrgaosComOrientacoesPendentes">
                        <cfelse>
                            <cfset myQuery = "rsOrgaosComOrientacoesPendentesParaTeste">
                            <h6>Quant. Órgãos com Orientações pendentes para envio de e-mail: <span class="azul_claro_correios_backgroundColor" style="color:#fff;padding-left:4px;padding-right:4px;border-radius: 5px;"><cfoutput>#NumberFormat(rsOrgaosComOrientacoesPendentesParaTeste.recordcount,"00")#</cfoutput></span></h6>

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
    <cfinclude template="includes/pc_footer.cfm">   

    <cfinclude template="includes/pc_sidebar.cfm">
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

                           

