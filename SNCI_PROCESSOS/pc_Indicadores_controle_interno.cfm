<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
		<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
        <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
		<style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}	
			.popover-body {
				text-align: justify!important;
			}
			.swal2-label{
				text-align:justify;
			}
			
			hr{
				display: block;
				margin-top: 5em!important;
				margin-bottom: 5em!important;
				margin-left: auto!important;
				margin-right: auto!important;
				border-style: inset!important;
				border-top: 3px solid rgba(0, 0, 0, 0.1)!important;
			}
		</style>
		
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" >
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
						
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Indicadores: <strong>Resultado Mensal</strong></h4>
						</div>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >

				<div style="display: flex;align-items: center;">
					<span style="color:#0083ca;font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>

				<div style="display: flex;align-items: center;">
                    <span style="color:#0083ca;font-size:20px;margin-right:10px">Mês:</span>
                    <div id="opcoesMes" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>

				<div id="divMesAnoCI"></div>

				<div id="divTabsIndicadores" class="card card-primary card-tabs"  style="widht:100%;">
					<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
						
						<ul class="nav nav-tabs" id="custom-tabs-one-tabAcomp" role="tablist" style="font-size:14px;">

							<li class="nav-item" style="">
								<a  class="nav-link  active" id="custom-tabs-one-DGCI_ECT-tab"   data-toggle="pill" href="#custom-tabs-one-DGCI_ECT" role="tab" aria-controls="custom-tabs-one-DGCI_ECT" aria-selected="true">DGCI ECT</a>
							</li>

							<li class="nav-item" style="">
								<a  class="nav-link " id="custom-tabs-one-DGCIporOrgaoSubord-tab"   data-toggle="pill" href="#custom-tabs-one-DGCIporOrgaoSubord" role="tab" aria-controls="custom-tabs-one-DGCIporOrgaoSubord" aria-selected="true">DGCI por Órgao Subordinador</a>
							</li>
							<li class="nav-item" style="">
								<a  class="nav-link  " id="custom-tabs-one-DGCIporGerencia-tab"   data-toggle="pill" href="#custom-tabs-one-DGCIporGerencia" role="tab" aria-controls="custom-tabs-one-DGCIporGerencia" aria-selected="true">DGCI por Gerência</a>
							</li>
							
							<li class="nav-item" style="">
								<a  class="nav-link  " id="custom-tabs-one-PRCIporOrgao-tab"   data-toggle="pill" href="#custom-tabs-one-PRCIporOrgao" role="tab" aria-controls="custom-tabs-one-PRCIporOrgao" aria-selected="true">PRCI por Órgao</a>
							</li>

							<li class="nav-item" style="">
								<a  class="nav-link  " id="custom-tabs-one-SLNCporOrgao-tab"   data-toggle="pill" href="#custom-tabs-one-SLNCporOrgao" role="tab" aria-controls="custom-tabs-one-SLNCporOrgao" aria-selected="true">SLNC por Órgao</a>
							</li>

							<li class="nav-item" style="">
								<a  class="nav-link" id="custom-tabs-one-PRCI-tab"   data-toggle="pill" href="#custom-tabs-one-PRCI" role="tab" aria-controls="custom-tabs-one-PRCI" aria-selected="true">PRCI - Detalhes</a>
							</li>
							
							<li class="nav-item" style="">
								<a  class="nav-link " id="custom-tabs-one-SLNC-tab"   data-toggle="pill" href="#custom-tabs-one-SLNC" role="tab" aria-controls="custom-tabs-one-SLNC" aria-selected="true">SLNC - Detalhes</a>
							</li>
							
						</ul>
					</div>
					<div class="card-body">
						<div class="tab-content " id="custom-tabs-one-tabContent" >

							<div disable class="tab-pane fade active show " id="custom-tabs-one-DGCI_ECT"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCI_ECT-tab" >														
								<div id="divIndicadorDGCI_ECT" ></div>
							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-DGCIporOrgaoSubord"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCIporOrgaoSubord-tab" >														
								<div id="divIndicadorDGCIporOrgaoSubord" ></div>
							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-DGCIporGerencia"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCIporGerencia-tab" >														
								<div id="divIndicadorDGCIporGerencia" ></div>
							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-PRCIporOrgao"  role="tabpanel" aria-labelledby="custom-tabs-one-PRCIporOrgao-tab" >														
								<div id="divIndicadorPRCIporOrgao" ></div>
							</div>

							<div disable class="tab-pane fade  " id="custom-tabs-one-SLNCporOrgao"  role="tabpanel" aria-labelledby="custom-tabs-one-SLNCporOrgao-tab" >														
								<div id="divIndicadorSLNCporOrgao" ></div>
							</div>

							<div disable class="tab-pane fade" id="custom-tabs-one-PRCI"  role="tabpanel" aria-labelledby="custom-tabs-one-PRCI-tab" >														
								<div id="divIndicadorDetalhesPRCI" ></div>
							</div>
							
							<div disable class="tab-pane fade " id="custom-tabs-one-SLNC"  role="tabpanel" aria-labelledby="custom-tabs-one-SLNC-tab" >								
								<div id="divIndicadorDetalhesSLNC" ></div>
							</div>			
							
						</div>
					</div>
					
				</div>


				
					<div id="divIndicadorDetalhes" ></div>


				
			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="pc_Footer.cfm">
	</div>
    <!-- ./wrapper -->
    <cfinclude template="pc_Sidebar.cfm">

    <script language="JavaScript">
    
        $(document).ready(function(){
			$(".content-wrapper").css("height", "auto");
			$('#divTabsIndicadores').hide();
			
			// Obtém o ano atual
			const currentYear = new Date().getFullYear();

			// Cria um array de anos, começando em 2023 e indo até o ano atual, em ordem crescente
			const yearRange = Array(currentYear - 2018).fill().map((_, i) => currentYear - i);

			// Mapeia cada ano para um botão de opção de rádio com o ano como rótulo e valor
			const radioButtonsAno = yearRange.map((year, i) => {
				// Define a classe "active" para o botão de opção de rádio do ano atual
				const checkedClass = year === currentYear ? " active" : "";
				const label = `${year}`;
				const input = `<input type="radio" name="ano" value="${year}" id="option_a${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
				const radioButton = `<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="efeito-grow btn bg-yellow${checkedClass}">${input}${label}</label><br>`;
				return radioButton;
			}).reverse(); // Inverte a ordem dos botões de opção de rádio para que o ano mais recente apareça por último

			// Adiciona os botões de opção de rádio ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').html(radioButtonsAno.join(''));

			// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente
			const monthNames = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];
			const currentMonth = new Date().getMonth();
			const monthRange = monthNames.slice(0, currentYear === parseInt($('input[name=ano]:checked').val()) ? currentMonth  : 12);

			// Mapeia cada mês para um botão de opção de rádio com o número do mês como valor e o nome do mês como rótulo
			const radioButtonsMes = monthRange.map((month, i) => {
				const checkedClass = "";
				const label = `${month}`;
				const input = `<input type="radio" name="mes" value="${i + 1}" id="option_b${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
				const radioButton = `<label style="border:none!important;border-radius:10px!important;margin-left:1px" class="efeito-grow btn bg-blue${checkedClass}">${input}${label}</label><br>`;
				return radioButton;
			});

			// Adiciona os botões de opção de rádio ao elemento HTML com o ID "opcoesMes"
			$('#opcoesMes').html(radioButtonsMes.join(''));

			// Adiciona um ouvinte de eventos ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').on('change', function() {
				$('#divTabsIndicadores').hide();
				$('#divIndicadorDetalhes').html('');
				$('#divMesAnoCI').html('');
				// Obtém o ano selecionado
				const selectedYear = parseInt($('input[name=ano]:checked').val());

				// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente, com base no ano selecionado
				const monthRange = monthNames.slice(0, selectedYear === currentYear ? currentMonth : 12);

				// Mapeia cada mês para um botão de opção de rádio com o número do mês como valor e o nome do mês como rótulo
				const radioButtonsMes = monthRange.map((month, i) => {
					const checkedClass = "";
					const label = `${month}`;
					const input = `<input type="radio" name="mes" value="${i + 1}" id="option_b${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
					const radioButton = `<label style="border:none!important;border-radius:10px!important;margin-left:1px" class="efeito-grow btn bg-blue${checkedClass}">${input}${label}</label><br>`;
					return radioButton;
				});

				// Adiciona os botões de opção de rádio atualizados ao elemento HTML com o ID "opcoesMes"
				$('#opcoesMes').html(radioButtonsMes.join(''));
			});

			

            
        }); 

		$('#opcoesMes').on('change', function() {
			$('#divTabsIndicadores').hide();
			$('#divIndicadorDetalhes').html('');
			$('#divMesAnoCI').html('');
			$('#divIndicadorDGCI_ECT').html('');
			// Obtém o ano selecionado		
			let selectedYear = parseInt($('input[name=ano]:checked').val());	
			// Obtém o mês selecionado
			let selectedMonth = parseInt($('input[name=mes]:checked').val());

			


			$('#modalOverlay').modal('show')
			setTimeout(function() {	

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"formIndicadoresCI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDetalhes').html(result);//INSERE OS INDICADORES NA DIV
						// Armazenar o conteúdo das divs de detalhes
						let conteudoDGCI_ECT = $('#divCardDGCIectMes').html();
						let conteudoDGCI_ECT_acumulado = $('#divCardDGCIectAcumulado').html();
						let conteudoDGCIporOrgaoSubord = $('#divDGCIporOrgaoSubord').html();
						let conteudoDGCIporGerencia = $('#divDGCIporGerencia').html();
						let conteudoPRCIporOrgao = $('#divPRCIporOrgao').html();
						let conteudoSLNCporOrgao = $('#divSLNCporOrgao').html();
						let conteudoDetalhesPRCI = $('#divDetalhePRCI').html();
						let conteudoDetalhesSLNC = $('#divDetalheSLNC').html();
						let conteudoDivMesAnoCI = $('#divMesAno').html();
						

						// Limpar o conteúdo das divs de detalhes
						$('#divCardDGCIectMes').html('');
						$('#divCardDGCIectAcumulado').html('');
						$('#divIndicadorDGCIporOrgaoSubord').html('');
						$('#divIndicadorDGCIporGerencia').html('');
						$('#divIndicadorPRCIporOrgao').html('');
						$('#divIndicadorSLNCporOrgao').html('');
						$('#divIndicadorDetalhesPRCI').html('');
						$('#divIndicadorDetalhesSLNC').html('');
						$('#divMesAnoCI').html('');
						
						// Adicionar o conteúdo às divs de detalhes das abas
						$('#divIndicadorDGCI_ECT').append(conteudoDGCI_ECT);
						$('#divIndicadorDGCI_ECT').append(conteudoDGCI_ECT_acumulado);
						$('#divIndicadorDGCIporOrgaoSubord').append(conteudoDGCIporOrgaoSubord);
						$('#divIndicadorDGCIporGerencia').append(conteudoDGCIporGerencia);
						$('#divIndicadorPRCIporOrgao').append(conteudoPRCIporOrgao);
						$('#divIndicadorSLNCporOrgao').append(conteudoSLNCporOrgao);
						$('#divIndicadorDetalhesPRCI').append(conteudoDetalhesPRCI);
						$('#divIndicadorDetalhesSLNC').append(conteudoDetalhesSLNC);
						$('#divMesAnoCI').append(conteudoDivMesAnoCI);

						// Esconder o conteúdo original
						$('#divIndicadorDetalhes').html('');

						// Ajustar altura
						$(".content-wrapper").css("height", "auto");

						$('#divTabsIndicadores').show();

						$('#modalOverlay').delay(1000).hide(0, function() {
				 			$('#modalOverlay').modal('hide');
				 		});
						
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
							$('#divTabsIndicadores').hide();
							$('#divIndicadorDetalhes').html('');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

			}, 1000);
		});


		
    </script>


</body>
</html>









