<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">

    <!-- Font Awesome -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/fontawesome.min.css">
	<!-- Tempusdominus Bootstrap 4 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
	<!-- iCheck -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
	
	<!-- overlayScrollbars -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
	<!-- Daterange picker -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/daterangepicker/daterangepicker.css">

	<!-- SweetAlert2 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.css">
	<!-- Toastr -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/toastr/toastr.css">
	<!-- Bootstrap4 Duallistbox -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/bootstrap4-duallistbox/bootstrap-duallistbox.css">
	<!-- dropzonejs -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/dropzone/min/dropzone.min.css">
	<!-- DataTables -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-buttons/css/buttons.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-select/css/select.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-scroller/css/scroller.bootstrap4.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/datatables-searchpanes/css/searchPanes.bootstrap4.min.css">
		
	<!-- Select2 -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/select2/css/select2.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">
 
	<!-- Tour -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/tour/dist/css/hopscotch.css">

    <!-- Theme style -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/adminlte.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/stylesSNCI.css">

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
                    <div class="row mb-2" style="margin-top:20px;margin-bottom:80px;">
                        <div class="col-sm-6">
                            <h5 >Bem vindo ao SNCI, <span id="nomeUsuario"><cfoutput>#application.rsUsuarioParametros.pc_usu_nome#</cfoutput></span> !</h5>
                            <h4>Módulo: Processos  <!--<cfif application.rsUsuarioParametros.pc_org_controle_interno eq 'N' and application.rsUsuarioParametros.pc_usu_perfil neq 13><i id="start-tour" style="color:#8cc63f" class="fas fa-question-circle grow-icon"></i></cfif>--></h4>
                        </div>
                       
                    </div>
                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>     
                        <div  id="alertasOAdiv"></div>
                    </cfif>

                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
                        <div  id="alertasCIdiv"></div>
                    </cfif>
                    
                    <cfinclude template="pc_notas_versao.cfm">


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

        // Obtém o valor de application.rsUsuarioParametros.pc_org_controle_interno e armazena na variável 'ci'
        <cfoutput>
            var ci = '#application.rsUsuarioParametros.pc_org_controle_interno#';
            var orgao = '#application.rsUsuarioParametros.pc_org_sigla#';
            var orgaoSubordinador = '#application.rsOrgaoSubordinados.recordcount#';
        </cfoutput>
        
        // Espera até que o documento esteja totalmente carregado
        $(document).ready(function() {
            // Define a altura da classe '.content-wrapper' como 'auto'
            $(".content-wrapper").css("height", "auto");

            // Verifica o valor de 'ci' e exibe os alertas apropriados
            if (ci === 'N') {
                mostraAlertasOrgaoAvaliado();
            } else {
                mostraAlertasControleInterno();
            }

            // Associa a função ao clique no elemento com o ID 'start-tour'
            // $('#start-tour').on('click', function() {
            //     // Encerra o tour atual antes de começar outro
            //     hopscotch.endTour();
            //     // Configura traduções personalizadas para o guia Hopscotch, se houver
            //     hopscotch.configure({ i18n: customI18n });
            //     // Inicia o tour definido no objeto 'tour'
            //     hopscotch.startTour(tour);
            // });

            // Configurações personalizadas para as traduções do guia Hopscotch
            // var customI18n = {
            //     nextBtn: 'Próximo',
            //     prevBtn: 'Anterior',
            //     doneBtn: 'Concluir',
            //     skipBtn: 'Pular',
            //     closeTooltip: 'Fechar',
            // };

            // // Objeto 'tour' contendo as etapas do guia Hopscotch
            // const tour = {
            //     id: 'orgaoAvaliado-inicio-tour',
            //     steps: [
                    
            //         {
            //             title: '<p style="font-size:20px">Bem-vindo ao SNCI - Processos! </p>',
            //             content: 'Sempre que você encontrar este ícone <i style="color:#8cc63f" class="fas fa-question-circle fa-2x"></i>, clique nele para realizar um tour sobre às funcionalidades da página que está sendo visualizada.<br><br>Clique em "Próximo" para iniciar um tour nesta página ou no "X" para encerrar.',
            //             target: 'start-tour',
            //             placement: 'bottom',
            //             width: 450,
            //             xOffset: -15,
            //         },

            //         {
            //             title: 'Informações do usuário',
            //             content: 'Confira aqui sua lotação e perfil.<br>Caso haja algum erro, entre em contato com a área de controle interno de sua SE ou CS.',
            //             target: '.user-panel',
            //             placement: 'right',  
            //             width: 450,                                                   
            //         },
            //         {
            //             title: 'Nome do usuário',
            //             content: 'Confira aqui seu nome completo.<br>Caso haja algum erro, entre em contato com a área de controle interno de sua SE ou CS.',
            //             target: 'nomeUsuario',
            //             placement: 'bottom',
            //             width: 450,
            //             yOffset: -10,
            //             onNext: function() {
            //                 if(!$('#rowAlertaOrgaoAvaliado').length > 0){
                                
            //                     // Criar a div com 200px de altura e largura da página
            //                     var divAlerta = $('<div></div>').css({
            //                         height: '200px',
            //                         width: '100%',
            //                         border: '2px solid red', // Personalize o estilo conforme necessário
            //                     });

            //                     // Adicionar a div ao elemento alvo com o ID "alertasOAdiv"
            //                     $('#alertasOAdiv').append(divAlerta);
            //                 }
            //             },
                        
            //         },
            //         {
            //             title: 'Alertas',
            //             content: 'Nesta área, você será alertado sobre as pendências do seu órgão de lotação e/ou seus órgãos subordinados.<br>Obs: Se estiver em branco, significa que nenhuma pendência foi encontrada.',
            //             target: 'alertasOAdiv',
            //             placement: 'top',
            //             width: 680,
            //             onNext: function() {
            //                 $("#Acompanhamento").addClass("menu-is-opening menu-open targetBorder");
            //                 if(!$('#rowAlertaOrgaoAvaliado').length > 0){
            //                     $('#alertasOAdiv').html('');
            //                 }
            //             },
                        
            //         },
            //         {
            //             title: 'Acompanhamento',
            //             content: 'Clicando aqui, você visualizará as Medidas/Orientações para regularização e as Propostas de Melhoria pendentes.',
            //             target: 'Acompanhamento',
            //             placement: 'bottom',
            //             width: 450,
            //             onNext: function() {
            //                 $("#FAQperguntasfrequentes").addClass("menu-is-opening menu-open");
            //                 $("#Acompanhamento").removeClass("menu-is-opening menu-open");
            //             },
            //             onPrev: function() {
            //                 $("#Acompanhamento").removeClass("menu-is-opening menu-open");    
            //             }
                        
            //         },
            //         {
            //             title: 'FAQ (perguntas frequentes)',
            //             content: 'Clicando aqui, você encontrará respostas para as perguntas mais frequentes feitas pelos usuários à equipe do controle interno.',
            //             target: 'FAQperguntasfrequentes',
            //             placement: 'bottom',
            //             width: 450,
            //             onNext: function() {
            //                 if(orgaoSubordinador==='0'){
            //                     $("#ConsultasEmAcomp").addClass("menu-is-opening menu-open");
            //                     $("#ConsultasEmAcomp #ConsultaporOrientacao a").addClass("active");
            //                     $("#FAQperguntasfrequentes").removeClass("menu-is-opening menu-open");
            //                 }else{

            //                     $("#ControledasDistribuicoes").addClass("menu-is-opening menu-open");
            //                     $("#FAQperguntasfrequentes").removeClass("menu-is-opening menu-open");
            //                 }
            //             },
            //             onPrev: function() {
            //                 $("#Acompanhamento").addClass("menu-is-opening menu-open");
            //                 $("#FAQperguntasfrequentes").removeClass("menu-is-opening menu-open");    
            //             }
            //         },
            //         //se application.rsOrgaoSubordinados for maior que 0, exibe o tour do target ControledasDistribuicoes
                    
                       
            //             {
            //                 title: 'Controle das Distribuições',
            //                 content: 'Clicando aqui, você poderá visualizar e controlar as Orientações e Propostas de Melhoria distribuídas pelo órgão ' + orgao + ' para seus órgãos subordinados.',
            //                 target: 'ControledasDistribuicoes',
            //                 placement: 'bottom',
            //                 width: 450,
            //                 onNext: function() {
            //                     $("#ConsultasEmAcomp").addClass("menu-is-opening menu-open");
            //                     $("#ConsultasEmAcomp #ConsultaporOrientacao a").addClass("active");
            //                     $("#ControledasDistribuicoes").removeClass("menu-is-opening menu-open");
                               
            //                 },
            //                 onPrev: function() {
            //                     $("#ControledasDistribuicoes").removeClass("menu-is-opening menu-open");
            //                     $("#FAQperguntasfrequentes").addClass("menu-is-opening menu-open");
            //                 }
            //             },
                   
                    

            //         {
            //             title: 'Consulta por Orientação (Processos Em Acompanhamento)',
            //             content: 'Clicando aqui, você poderá consultar:<br>- As Medidas/Orientações para regularização sob responsabilidade do seu órgão de lotação e/ou órgãos subordinados, dos processsos que estão em acompanhamento;<br>- As Medidas/Orientações para regularização de todos os processos, em acompanhamento, que possuem sua lotação como órgão avaliado.',
            //             target: '#ConsultasEmAcomp #ConsultaporOrientacao',
            //             placement: 'bottom',
            //             width: 550,
            //             onNext: function() {
            //                 $("#ConsultasEmAcomp #ConsultaporProcesso a").addClass("active");
            //                 $("#ConsultasEmAcomp #ConsultaporOrientacao a").removeClass("active");
            //             },
            //             onPrev: function() {
            //                 if(orgaoSubordinador==='0'){
            //                      $("#FAQperguntasfrequentes").addClass("menu-is-opening menu-open");
            //                 }else{
            //                     $("#ControledasDistribuicoes").addClass("menu-is-opening menu-open");
            //                 }
            //                 $("#ConsultasEmAcomp").removeClass("menu-is-opening menu-open");
            //                 $("#ConsultasEmAcomp #ConsultaporOrientacao a").removeClass("active");    
            //             }
                        
            //         },
            //         {
            //             title: 'Consulta por Processo (Em Acompanhamento)',
            //             content: 'Clicando aqui, você poderá consultar:<br>- Os processos, em acompanhamento, que possuem orientações sob responsabilidade do seu órgão de lotação e/ou órgãos subordinados;<br>- Os processos, em acompanhamento, que possuem sua lotação como órgão avaliado.',
            //             target: '#ConsultasEmAcomp #ConsultaporProcesso',
            //             placement: 'bottom',
            //             width: 450,
            //             onNext: function() {
            //                 $("#ConsultasEmAcomp").removeClass("menu-is-opening menu-open");
            //                 $("#ConsultasEmAcomp #ConsultaporProcesso a").removeClass("active");
            //                 $("#ConsultasFinalizados").addClass("menu-is-opening menu-open");
            //                 $("#ConsultasFinalizados #ConsultaporOrientacao a").addClass("active");
                             
            //             },
            //             onPrev: function() {
            //                 $("#ConsultasEmAcomp #ConsultaporProcesso a").removeClass("active");
            //                 $("#ConsultasEmAcomp #ConsultaporOrientacao a").addClass("active");    
            //             },
                        
                    
                        
            //         },


            //         {
            //             title: 'Consulta por Orientação (Processos Finalizados)',
            //             content: 'Clicando aqui, você poderá consultar:<br>- As Medidas/Orientações para regularização sob responsabilidade do seu órgão de lotação e/ou órgãos subordinados, dos processsos que estão finalizados;<br>- As Medidas/Orientações para regularização de todos os processos finalizados, que possuem sua lotação como órgão avaliado.',
            //             target: '#ConsultasFinalizados #ConsultaporOrientacao',
            //             placement: 'bottom',
            //             width: 450,
            //             onNext: function() {
            //                 //$("#ConsultasFinalizados").addClass("menu-is-opening menu-open");
            //                 $("#ConsultasFinalizados #ConsultaporProcesso a").addClass("active");
            //                 $("#ConsultasFinalizados #ConsultaporOrientacao a").removeClass("active");
            //             },
            //             onPrev: function() {
            //                 $("#ConsultasFinalizados").removeClass("menu-is-opening menu-open");
            //                 $("#ConsultasFinalizados #ConsultaporProcesso a").removeClass("active");  
            //                 $("#ConsultasEmAcomp").addClass("menu-is-opening menu-open");  
            //                 $("#ConsultasEmAcomp #ConsultaporProcesso a").addClass("active");
            //             }
                        
            //         },
            //         {
            //             title: 'Consulta por Processo (Finalizados)',
            //             content: 'Clicando aqui, você poderá consultar:<br>- Os processos finalizados, que possuem orientações sob responsabilidade do seu órgão de lotação e/ou órgãos subordinados;<br>- Os processos finalizados, que possuem sua lotação como órgão avaliado.',
            //             target: '#ConsultasFinalizados #ConsultaporProcesso',
            //             placement: 'bottom',
            //             width: 450,
            //             onNext: function() {
            //                 $("#ConsultasFinalizados").removeClass("menu-is-opening menu-open");
            //                 $("#ConsultasFinalizados #ConsultaporProcesso a").removeClass("active");   
            //             },
            //             onPrev: function() {
            //                 $("#ConsultasFinalizados #ConsultaporProcesso a").removeClass("active");
            //                 $("#ConsultasFinalizados #ConsultaporOrientacao a").addClass("active");    
            //             },
                        
                    
                        
            //         },





            //         {
            //             title: '<p style="font-size:20px">Fim do Tour</p>',
            //             content: '<p>Finalizamos nosso tour pelas funcionalidades da página inicial do SNCI.</p><p></p>Lembre-se: sempre que você encontrar este ícone <i style="color:#8cc63f" class="fas fa-question-circle fa-2x"></i>, clique nele para realizar um tour sobre às funcionalidades da página que está sendo visualizada.',
            //             target: 'start-tour',
            //             placement: 'bottom',
            //             width: 500,
            //             xOffset: -15,
            //             showPrevButton:false,
                        
            //         },
                    
            //     ],
            //         showPrevButton: true,
            //         i18n: customI18n, // Use as opções de i18n personalizadas definidas acima
            //         onEnd: function() {
            //                 $("#Consultas").removeClass("menu-is-opening menu-open");
            //                 $("#ConsultaporProcesso a").removeClass("active");  
            //                 if(!$('#rowAlertaOrgaoAvaliado').length > 0){
            //                     $('#alertasOAdiv').html('');
            //                 }
            //             },
            //         onClose: function() {
            //                 $("li").removeClass("menu-is-opening menu-open");
            //                 $("a").removeClass("active");  
            //                 if(!$('#rowAlertaOrgaoAvaliado').length > 0){
            //                     $('#alertasOAdiv').html('');
            //                 }
            //             },
            // };

            // // Função para iniciar o tour automaticamente
			// function iniciarTourAutomaticamente() {
            //     //hopscotch.endTour();
			// 	hopscotch.configure({ i18n: customI18n }); // Configura as traduções personalizadas, se houver
			// 	hopscotch.startTour(tour);
            //     localStorage.setItem("skipTour", 'true');
			// }

            <cfoutput>
                var usuarioControleInterno = '#application.rsUsuarioParametros.pc_org_controle_interno#';
                var usuarioPerfil = '#application.rsUsuarioParametros.pc_usu_perfil#';
            </cfoutput>

			// Chame a função para iniciar o tour após a página ser carregada
            //Se o usuário não for do controle interno e não for o perfil 13 (CONSULTA), inicia o tour automaticamente
            if(usuarioControleInterno == 'N' && usuarioPerfil != '13'){
                // Verifica se a preferência já foi marcada como "true"
                // var skipTourValue = localStorage.getItem("skipTour");
                // if (skipTourValue !== "true") {
                //     iniciarTourAutomaticamente();
                // }
            }
			 

            // Função para gerar os dados para os indicadores
            // Obtém o ano atual
			const currentYear = new Date().getFullYear();
			// Obtém o mês atual
			const currentMonth = new Date().getMonth() + 1;

            //executar a partir do primeiro dia do mês para gerar os dados do mês anterior
            const firstDay = new Date(currentYear, currentMonth - 1, 1);
          
           //se a data de hoje for maior ou igual ao primeiro dia do mês e se o usuário for do controle interno, executa a função 
            if (new Date() >= firstDay && usuarioControleInterno == 'S') {
               //ontém o mês anterior
                const previousMonth = new Date().getMonth();
                // Obtém o ano atual e se o mês for janeiro, subtrai 1 do ano
                const previousYear = new Date().getMonth() === 0 ? new Date().getFullYear() - 1 : new Date().getFullYear();
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
                        if(result == -1 && usuarioPerfil != '11'){
                            $('#modalOverlay').delay(1000).hide(0, function() {
                                $('#modalOverlay').modal('hide');
                                $('#opcoesMes').find('label').removeClass('active');
                                Swal.fire('Não estão cadastrados e ativos, todos os pesos dos indicadores para <strong>' + previousYear + '</strong>. Sem eles, os dados dos indicadores não poderão ser gerados.', '', 'info')
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

        
    </script>

</body>



</html>
