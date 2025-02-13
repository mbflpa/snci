<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
    <link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/animate.min.css">
   
</head>





<body class="layout-footer-fixed hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    
	
	<div class="wrapper">

		
		<cfinclude template="pc_NavBar.cfm">

		<!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper" >
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2" style="margin-bottom:80px;">
                        <div class="col-sm-12">
                            <h5 >Bem vindo ao SNCI, <span id="nomeUsuario"><cfoutput>#application.rsUsuarioParametros.pc_usu_nome#</cfoutput></span> !</h5>
                            <h4>Módulo: Processos  <!--<cfif application.rsUsuarioParametros.pc_org_controle_interno eq 'N' and application.rsUsuarioParametros.pc_usu_perfil neq 13><i id="start-tour" style="color:#8cc63f" class="fas fa-question-circle grow-icon"></i></cfif>--></h4>
                        </div>
                       
                    </div>
                    
                    <div id="menuRapidoDiv" ></div>    

                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>     
                        <div  id="alertasOAdiv"></div>
                    </cfif>

                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
                        <div  id="alertasCIdiv"></div>
                    </cfif>

                    <div id="formFaqDiv"></div>

                    <cfinclude template="pc_notas_versao.cfm">
                    


                </div><!-- /.container-fluid -->
            </section>
        </div>
        <!-- /.content-wrapper -->
    
    <!-- Footer -->
    <cfinclude template="pc_Footer.cfm">   
	</div>
	<!-- ./wrapper -->
    <cfinclude template="pc_Sidebar.cfm">


	

    <script language="JavaScript">

        // Obtém o valor de application.rsUsuarioParametros.pc_org_controle_interno e armazena na variável 'ci'
        <cfoutput>
            var ci = '#application.rsUsuarioParametros.pc_org_controle_interno#';
            var orgao = '#application.rsUsuarioParametros.pc_org_sigla#';
            var orgaoSubordinador = '#application.rsOrgaoSubordinados.recordcount#';
        </cfoutput>
        
        // Espera até que o documento esteja totalmente carregado
        $(window).on('load', function() {
            
            
            menuRapido();
            // Verifica o valor de 'ci' e exibe os alertas apropriados
            if (ci === 'N') {
                mostraAlertasOrgaoAvaliado();
            } else {
                mostraAlertasControleInterno();
            }
            mostraFormFaq();

            <cfoutput>
                var usuarioControleInterno = '#application.rsUsuarioParametros.pc_org_controle_interno#';
                var usuarioPerfil = '#application.rsUsuarioParametros.pc_usu_perfil#';
            </cfoutput>

						 

            // Função para gerar os dados para os indicadores
            // Obtém o ano atual
            const currentYear = new Date().getFullYear();
            // Obtém o mês atual (adiciona 1 porque os meses começam em 0)
            const currentMonth = new Date().getMonth() + 1;

            // Executar a partir do primeiro dia do mês para gerar os dados do mês anterior
            const firstDay = new Date(currentYear, currentMonth - 1, 1);

            // Se a data de hoje for maior ou igual ao primeiro dia do mês e se o usuário for do controle interno, executa a função
            if (new Date() >= firstDay && usuarioControleInterno == 'S') {
                // Calcula o mês e o ano anterior
                const now = new Date();
                const previousMonth = now.getMonth() === 0 ? 12 : now.getMonth(); // Janeiro (0) vira dezembro (12)
                const previousYear = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();

                console.log("Gerar dados para indicadores do mês anterior: " + previousMonth + "/" + previousYear);
                // Executa a função para gerar os dados para os indicadores
                $.ajax({//AJAX PARA CONSULTAR OS INDICADORES
                    type: "post",
                    url: "cfc/pc_cfcIndicadores_gerarDados.cfc",
                    data:{
                        method:"verificaExisteDadosGerados",
                        ano:previousYear,
                        mes:previousMonth
                    },
                    async: true,
                    success: function(result) {
                        if(result == -1 && usuarioPerfil == '11'){
                            $('#modalOverlay').delay(1000).hide(0, function() {
                                $('#modalOverlay').modal('hide');
                                $('#opcoesMes').find('label').removeClass('active');
                                Swal.fire({
                                    title: 'Não estão cadastrados e ativos, todos os pesos dos indicadores para <strong>' + previousYear + '</strong>. Sem eles, os dados dos indicadores não poderão ser gerados.',
                                    html: logoSNCIsweetalert2(''),
                                    icon: 'info'
                                });
                            });
                        }else{
                            if(result == 0){
                                gerarDados(previousMonth, previousYear);
                            }
                        }
                    }, 
                    error: function(xhr, ajaxOptions, thrownError) {
                        $('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
                        $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
                        $('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
                            
                    }
                })//fim ajax
            }//

            $(".menuRapidoGrid .menuRapido_iconGrid").each(function (index) {
                setTimeout(() => {    
                    $(this).delay(100 * index).queue(function (next) {
                        $(this).addClass("menuRapido_iconGrid_animacao");
                        setTimeout(() => {
                            $(this).removeClass("menuRapido_iconGrid_animacao");
                        }, 200); // Tempo para remover a classe após a animação (500ms)
                        next();
                    });
                }, 1000);     
            });
            //se o usuário for do perfil 11 (CI - MASTER ACOMPANHAMENTO (Gestor Nível 4)), executa a função para enviar os e-mails de cobrança
            if (usuarioPerfil == '11') {
                executaRotinasEmailsCobranca();
            }

            $(".content-wrapper").css("height", "auto");
        });
       
        
        function gerarDados(previousMonth, previousYear){
             $.ajax({//AJAX PARA CONSULTAR OS INDICADORES
                type: "post",
                url: "cfc/pc_cfcIndicadores_gerarDados.cfc",
                data:{
                    method:"gerarDadosParaIndicadores",
                    ano:previousYear,
                    mes:previousMonth
                },
                async: true,
                success: function(result) {
                console.log("Dados para indicadores gerados com sucesso! "+previousMonth+"/"+previousYear);
                },
                        
                error: function(xhr, ajaxOptions, thrownError) {
                    $('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
                    $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
                    $('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
                        
                }
            })//fim ajax
        }

        //Funçao para executar ajax assincrono do método executaRotinasEmailsCobranca do cfc pc_cfcPaginasApoio.cfc
        function executaRotinasEmailsCobranca(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcPaginasApoio.cfc",
                data:{
                    method: "executaRotinasEmailsCobranca"
                },
                async: true
            })//fim ajax
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                    var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
                                + '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
                    const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
                    
                    swalWithBootstrapButtons.fire(
                        {...erroSistema}
                    )
                });
            })//fim fail
        }


        function mostraAlertasOrgaoAvaliado(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcAlertasIndex.cfc",
                data:{
                    method: "alertasOA"
                },
                async: false
            })//fim ajax
            .done(function(result) {
                $('#alertasOAdiv').html(result)
            })//fim done
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                    var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
                                + '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
                    const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
                    
                    swalWithBootstrapButtons.fire(
                        {...erroSistema}
                    )
                });
            })//fim fail
        }

        function mostraAlertasControleInterno(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcAlertasIndex.cfc",
                data:{
                    method: "alertasCI"
                },
                async: false
            })//fim ajax
            .done(function(result) {
                $('#alertasCIdiv').html(result)
            })//fim done
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                    var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
                                + '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
                    const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
                    
                    swalWithBootstrapButtons.fire(
                        {...erroSistema}
                    )
                });
            })//fim fail
        }

        function menuRapido(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcPaginasApoio.cfc",
                data:{
                    method: "dashboardMenuRapido"
                },
                async: false
            })//fim ajax
            .done(function(result) {
                $('#menuRapidoDiv').html(result)
            })//fim done
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                    var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
                                + '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
                    const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
                    
                    swalWithBootstrapButtons.fire(
                        {...erroSistema}
                    )
                });
            })//fim fail
        }

         function mostraFormFaq(){
            $.ajax({
                type: "post",
                url: "cfc/pc_cfcFaqs.cfc",
                data: {
                    method: "formFaqIndex"
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
