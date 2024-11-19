<cfprocessingdirective pageencoding = "utf-8">	


<cfquery name="rsOrientacaoSuspensaPrazoVencido" datasource="#application.dsn_processos#">
    SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
    FROM pc_avaliacao_orientacoes
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    WHERE pc_aval_orientacao_status = 16 and DATEDIFF(DAY, pc_aval_orientacao_dataPrevistaResp, GETDATE()) >0
    order by pc_aval_orientacao_dataPrevistaResp desc
</cfquery>

<cfquery name="rsOrientacaoSuspensa" datasource="#application.dsn_processos#">
    SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
    FROM pc_avaliacao_orientacoes
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    WHERE pc_aval_orientacao_status = 16 
    order by pc_aval_orientacao_dataPrevistaResp desc
</cfquery>

<cfquery name="verificarExecucao" datasource="#application.dsn_processos#">
    SELECT pc_rotina_ultima_execucao  
    FROM pc_rotinas_execucao_emails_log 
    WHERE pc_rotina_nome = <cfqueryparam value="rotinaDiaria" cfsqltype="cf_sql_varchar">
</cfquery>


<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">

</head>





<body class="layout-footer-fixed hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
	
	<div class="wrapper">

		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

		<!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">

      
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">

                    <div class="row mb-2" style="margin-bottom:0px!important;">
                        <div class="col-sm-12">
                            <h4>Rotina de Verificação das Orientações Suspensas Vencidas</h4>
                            <cfset ultima_execucao = '#DateFormat(verificarExecucao.pc_rotina_ultima_execucao, "dd/mm/yyyy")# às #TimeFormat(verificarExecucao.pc_rotina_ultima_execucao, "HH:mm")#'>
                            <div class="alert d-inline-flex align-items-center" style="background-color: #d52e44;border-color:#973450;color:#fff">
                                <i class="fas fa-calendar-alt" style="font-size: 3rem;margin-right:20px"></i>
                                <div>
                                    <cfif verificarExecucao.recordcount eq 0>
                                        <h5>Última execução automática: <b>ainda não executada</b> (executada diariamente)</h5>
                                    <cfelse>
                                        <h5>Última execução automática: <b><cfoutput>#ultima_execucao#</cfoutput></b> (executada diariamente)</h5>
                                    </cfif>
                                    <small>Obs.: Esta rotina é executada automaticamente sempre que um usuário do perfil CI - MASTER ACOMPANHAMENTO (Gestor Nível 4) entra no sistema.</small>
                                </div>
                            </div>                      
                        </div>
                    </div>

                    <br>
                    <cfoutput>
                        <li>Quantidade de Orientações Suspensas: <b>#rsOrientacaoSuspensa.recordcount#</b></li>
                        <!--table das orientações suspensas vencidas-->
                        <table class="table table-striped dataTable" id="tabelaOrientacaoSuspensaVencido" role="grid" aria-describedby="tabelaOrientacaoSuspensaVencido_info">
                            <thead>
                                <tr role="row">
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Processo: Ordenar colunas de forma ascendente" style="width: 100px;">Processo</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Orientação: Ordenar colunas de forma ascendente" style="width: 100px;">Orientação</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Data Prevista: Ordenar colunas de forma ascendente" style="width: 100px;">Data Prevista</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="rsOrientacaoSuspensa">
                                    <tr role="row" class="odd">
                                        <td>#pc_aval_processo#</td>
                                        <td>#pc_aval_orientacao_id#</td>
                                        <td>#DateFormat(pc_aval_orientacao_dataPrevistaResp,'dd/mm/yyyy')#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        <br>
                        <li>Quantidade de Orientações Suspensas Vencidas: <b>#rsOrientacaoSuspensaPrazoVencido.recordcount#</b></li>
                        <!--table das orientações suspensas vencidas-->
                        <table class="table table-striped dataTable" id="tabelaOrientacaoSuspensaVencido" role="grid" aria-describedby="tabelaOrientacaoSuspensaVencido_info">
                            <thead>
                                <tr role="row">
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Processo: Ordenar colunas de forma ascendente" style="width: 100px;">Processo</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Orientação: Ordenar colunas de forma ascendente" style="width: 100px;">Orientação</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaOrientacaoSuspensaVencido" rowspan="1" colspan="1" aria-label="Data Prevista: Ordenar colunas de forma ascendente" style="width: 100px;">Data Prevista</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="rsOrientacaoSuspensaPrazoVencido">
                                    <tr role="row" class="odd">
                                        <td>#pc_aval_processo#</td>
                                        <td>#pc_aval_orientacao_id#</td>
                                        <td>#DateFormat(pc_aval_orientacao_dataPrevistaResp,'dd/mm/yyyy')#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        <br>


                        <cfif rsOrientacaoSuspensaPrazoVencido.recordcount gt 0>
                            <div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
                                <div id="btSalvarDiv" >
                                    <button id="btnrotinaDiariaOrientacoesSuspensas" class="btn btn-block btn-primary " >Executar Rotina</button>
                                </div>      
                            </div>
                        </cfif>
                    </cfoutput>
                </div><!-- /.container-fluid -->
            </section>

        </div>
        <!-- /.content-wrapper -->
	</div>
	<!-- ./wrapper -->





<!-- Footer -->
<cfinclude template="pc_Footer.cfm">   

<cfinclude template="pc_Sidebar.cfm">	

    <script language="JavaScript">
        //cria click em um botão para um ajax para executar cffunction metodo rotinaDiariaOrientacoesSuspensas em pc_cfcPaginasApoio.cfc
        $(document).ready(function(){
            $("#btnrotinaDiariaOrientacoesSuspensas").click(function(){
                var mensagem = '';
                <cfoutput >
                     var emailUsuario = '#application.rsUsuarioParametros.pc_usu_email#';
                    <cfif FindNoCase("intranetsistemaspe", application.auxsite)>
                        mensagem = 'Deseja executar a rotina de verificação das orientações suspensas?<br>Esta rotina irá verificar os pontos suspensos vencidos e alterar o status para TRATAMENTO, irá inserir um posicionamento e enviará um e-mail de aviso para o órgão responsável.';  
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
                        mensagem = 'Deseja executar a rotina de verificação das orientações suspensas?<br>Esta rotina irá verificar os pontos suspensos vencidos e alterar o status para TRATAMENTO, irá inserir um posicionamento e enviará um e-mail de aviso para você como se fosse o órgão responsável.<br><br>ATENÇÃO: Esta rotina não irá enviar e-mail para os órgãos, apenas para você:<br>' + emailUsuario + '.';
                    </cfif>
                </cfoutput>
                Swal.fire({
                    html: logoSNCIsweetalert2(mensagem), 
                    title: 'Rotina de Verificação das Orientações Suspensas',
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
                                    method: "rotinaDiariaOrientacoesSuspensas",
                                },
                                async: false,
                                success: function(result) {
                                    $('#modalOverlay').delay(1000).hide(0, function() {
                                        $('#modalOverlay').modal('hide');

                                    // Espera pelo ok seleção do usuário
                                    Swal.fire({
                                            html: logoSNCIsweetalert2('Deseja atualizar a página para verificar o resultado?'), 
                                            title: 'Rotina executada com sucesso!',
                                            icon: 'success',
                                            showCancelButton: true,
                                            confirmButtonText: 'Sim',
                                            cancelButtonText: 'Não'
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                location.reload();
                                            }
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
                        