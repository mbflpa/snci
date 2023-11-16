<cfprocessingdirective pageencoding = "utf-8">	


<cfquery name="rsPontoSuspensoPrazoVencido" datasource="#application.dsn_processos#">
    SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
    FROM pc_avaliacao_orientacoes
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    WHERE pc_aval_orientacao_status = 16 and DATEDIFF(DAY, pc_aval_orientacao_dataPrevistaResp, GETDATE()) >0
    order by pc_aval_orientacao_dataPrevistaResp desc
</cfquery>

<cfquery name="rsPontoSuspenso" datasource="#application.dsn_processos#">
    SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
    FROM pc_avaliacao_orientacoes
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    WHERE pc_aval_orientacao_status = 16 
    order by pc_aval_orientacao_dataPrevistaResp desc
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

                    <div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
                        <div class="col-sm-6">
                            <h4>Rotina de Verificação dos Pontos Suspensos Vencidos</h4>
                        </div>
                    </div>

                    <br>
                    <cfoutput>
                        <li>Quantidade de Pontos Suspensos: <b>#rsPontoSuspenso.recordcount#</b></li>
                        <!--table dos pontos suspensos vencidos-->
                        <table class="table table-bordered table-striped dataTable" id="tabelaPontoSuspensoVencido" role="grid" aria-describedby="tabelaPontoSuspensoVencido_info">
                            <thead>
                                <tr role="row">
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Processo: Ordenar colunas de forma ascendente" style="width: 100px;">Processo</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Orientação: Ordenar colunas de forma ascendente" style="width: 100px;">Orientação</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Data Prevista: Ordenar colunas de forma ascendente" style="width: 100px;">Data Prevista</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="rsPontoSuspenso">
                                    <tr role="row" class="odd">
                                        <td>#pc_aval_processo#</td>
                                        <td>#pc_aval_orientacao_id#</td>
                                        <td>#DateFormat(pc_aval_orientacao_dataPrevistaResp,'dd/mm/yyyy')#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        <br>
                        <li>Quantidade de Pontos Suspensos Vencidos: <b>#rsPontoSuspensoPrazoVencido.recordcount#</b></li>
                        <!--table dos pontos suspensos vencidos-->
                        <table class="table table-bordered table-striped dataTable" id="tabelaPontoSuspensoVencido" role="grid" aria-describedby="tabelaPontoSuspensoVencido_info">
                            <thead>
                                <tr role="row">
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Processo: Ordenar colunas de forma ascendente" style="width: 100px;">Processo</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Orientação: Ordenar colunas de forma ascendente" style="width: 100px;">Orientação</th>
                                    <th class="sorting" tabindex="0" aria-controls="tabelaPontoSuspensoVencido" rowspan="1" colspan="1" aria-label="Data Prevista: Ordenar colunas de forma ascendente" style="width: 100px;">Data Prevista</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="rsPontoSuspensoPrazoVencido">
                                    <tr role="row" class="odd">
                                        <td>#pc_aval_processo#</td>
                                        <td>#pc_aval_orientacao_id#</td>
                                        <td>#DateFormat(pc_aval_orientacao_dataPrevistaResp,'dd/mm/yyyy')#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        <br>


                        <cfif rsPontoSuspensoPrazoVencido.recordcount gt 0>
                            <div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
                                <div id="btSalvarDiv" >
                                    <button id="btnRotinaPontosSuspensos" class="btn btn-block btn-primary " >Executar Rotina</button>
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
        //cria click em um botão para um ajax para executar cffunction metodo rotinaPontosSuspensos em pc_cfcPaginasApoio.cfc
        $(document).ready(function(){
            $("#btnRotinaPontosSuspensos").click(function(){
                Swal.fire({
                    html: logoSNCIsweetalert2('Deseja executar a rotina de verificação dos pontos suspensos?<br>Esta rotina irá verificar os pontos suspensos vencidos e alterar o status para TRATAMENTO, irá inserir um posicionamento e enviará um e-mail de aviso para você como se fosse o órgão responsável.'), 
                    title: 'Rotina de Verificação dos Pontos Suspensos',
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
                                    method: "rotinaPontosSuspensos",
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
                        