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

							<li class="nav-item" style="text-align: center;f">
								<a  class="nav-link  active" id="custom-tabs-one-DGCI_ECT-tab"   data-toggle="pill" href="#custom-tabs-one-DGCI_ECT" role="tab" aria-controls="custom-tabs-one-DGCI_ECT" aria-selected="true">DGCI ECT</a>
							</li>

							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link " id="custom-tabs-one-DGCIporOrgaoSubord-tab"   data-toggle="pill" href="#custom-tabs-one-DGCIporOrgaoSubord" role="tab" aria-controls="custom-tabs-one-DGCIporOrgaoSubord" aria-selected="true">DGCI<br>Órgão Subord.</a>
							</li>
							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link  " id="custom-tabs-one-DGCIporGerencia-tab"   data-toggle="pill" href="#custom-tabs-one-DGCIporGerencia" role="tab" aria-controls="custom-tabs-one-DGCIporGerencia" aria-selected="true">DGCI<br>Órgão Resp.</a>
							</li>
							
							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link  " id="custom-tabs-one-PRCIporOrgaoSubordinador-tab"   data-toggle="pill" href="#custom-tabs-one-PRCIporOrgaoSubordinador" role="tab" aria-controls="custom-tabs-one-PRCIporOrgaoSubordinador" aria-selected="true">PRCI<br>Órgao Subord.</a>
							</li>

							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link  " id="custom-tabs-one-SLNCporOrgaoSubordinador-tab"   data-toggle="pill" href="#custom-tabs-one-SLNCporOrgaoSubordinador" role="tab" aria-controls="custom-tabs-one-SLNCporOrgaoSubordinador" aria-selected="true">SLNC<br>Órgao Subord.</a>
							</li>

							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link" id="custom-tabs-one-PRCI-tab"   data-toggle="pill" href="#custom-tabs-one-PRCI" role="tab" aria-controls="custom-tabs-one-PRCI" aria-selected="true">PRCI<br>Detalhes</a>
							</li>
							
							<li class="nav-item" style="text-align: center;">
								<a  class="nav-link " id="custom-tabs-one-SLNC-tab"   data-toggle="pill" href="#custom-tabs-one-SLNC" role="tab" aria-controls="custom-tabs-one-SLNC" aria-selected="true">SLNC<br>Detalhes</a>
							</li>
							
						</ul>
					</div>
					<div class="card-body">
						<div class="tab-content " id="custom-tabs-one-tabContent" >

							<div disable class="tab-pane fade active show " id="custom-tabs-one-DGCI_ECT"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCI_ECT-tab" >
												
								<div id="divIndicadorDGCI_ECT" ></div>
								<div id="divIndicadorDGCI_ECT_mes_a_mes" ></div>


							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-DGCIporOrgaoSubord"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCIporOrgaoSubord-tab" >	
							    <div><h5 style="color:#0083ca;margin-left: 10px">DGCI por órgão subordinador:</h5></div>														
								<div id="divIndicadorDGCIporOrgaoSubord" ></div>
							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-DGCIporGerencia"  role="tabpanel" aria-labelledby="custom-tabs-one-DGCIporGerencia-tab" >
							    <div style="margin-left: 10px">
									<h5 style="color:#0083ca;">DGCI por órgão responsável:</h5>
									<h6 >Atenção: Nesta tabela, também aparecerão os órgãos subordinadores que possuem ou possuíram orientações sob sua responsabilidade no período selecionado.</h6>
								</div>															
								<div id="divIndicadorDGCIporOrgaoResponsavel" ></div>
							</div>

							<div disable class="tab-pane fade " id="custom-tabs-one-PRCIporOrgaoSubordinador"  role="tabpanel" aria-labelledby="custom-tabs-one-PRCIporOrgaoSubordinador-tab" >	
								<div><h5 style="color:#0083ca;margin-left: 10px">PRCI por órgão subordinador:</h5></div>													
								<div id="divIndicadorPRCIporOrgaoSubordinador" ></div>
							</div>

							<div disable class="tab-pane fade  " id="custom-tabs-one-SLNCporOrgaoSubordinador"  role="tabpanel" aria-labelledby="custom-tabs-one-SLNCporOrgaoSubordinador-tab" >	
								<div><h5 style="color:#0083ca;margin-left: 10px">SLNC por órgão subordinador:</h5></div>													
								<div id="divIndicadorSLNCporOrgaoSubordinador" ></div>
							</div>

							<div disable class="tab-pane fade" id="custom-tabs-one-PRCI"  role="tabpanel" aria-labelledby="custom-tabs-one-PRCI-tab" >	
								<div><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do PRCI:</h5></div>									
								<div id="divIndicadorDetalhesPRCI" ></div>
							</div>
							
							<div disable class="tab-pane fade " id="custom-tabs-one-SLNC"  role="tabpanel" aria-labelledby="custom-tabs-one-SLNC-tab" >		
								<div><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do SLNC:</h5></div>						
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

	<!-- cfqquery que retorna os anos e meses que constam na coluna pc_indOrgao_ano da tabela pc_indicadores_porOrgao -->
	<cfquery name="getAnos" datasource="#application.dsn_processos#" timeout="120"  >
		SELECT DISTINCT pc_indOrgao_ano, pc_indOrgao_mes
		FROM pc_indicadores_porOrgao
		ORDER BY pc_indOrgao_ano, pc_indOrgao_mes asc
	</cfquery>

	
	<cfset data = ArrayNew(1)>
	<cfloop query="getAnos">
		<cfset anoMes = {ano=pc_indOrgao_ano, mes=pc_indOrgao_mes}>
		<cfset ArrayAppend(data, anoMes)>
	</cfloop>

    <script language="JavaScript">
    
        $(document).ready(function(){
			$(".content-wrapper").css("height", "auto");
			$('#divTabsIndicadores').hide();
			
			// Obtém o ano atual
			const currentYear = new Date().getFullYear();
			// Obtém os anos e meses da CFQUERY
			<cfoutput>
        		const data = #serializeJSON(data)#;
			</cfoutput>

			// Cria um objeto para armazenar os anos e meses
			const anosMeses = {};
			
			// Cria um array com os nomes dos meses
			const monthNames = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];

			// Preenche o objeto com os anos como chaves e os meses como valores
			data.forEach(item => {
				if (!anosMeses[item.ANO]) {
					anosMeses[item.ANO] = [];
				}
				anosMeses[item.ANO].push(monthNames[item.MES - 1]);
			});

      	  // Mapeia cada ano para um botão de opção de rádio com o ano como rótulo e valor
			const radioButtonsAno = Object.keys(anosMeses).map((ano, i) => {
				// Converte 'ano' para um número antes de comparar
				const checkedClass = Number(ano) === currentYear ? " active" : "";
				const label = `${ano}`;
				const input = `<input type="radio" name="ano" value="${ano}" id="option_a${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
				const radioButton = `<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="efeito-grow btn bg-yellow${checkedClass}">${input}${label}</label><br>`;
				return radioButton;
			});

			// Adiciona os botões de opção de rádio ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').html(radioButtonsAno.join(''));

			// Função para criar botões de opção de rádio para os meses
			function createMonthRadioButtons(selectedYear) {
				// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente, com base no ano selecionado
				const monthRange = anosMeses[selectedYear];

				// Mapeia cada mês para um botão de opção de rádio com o número do mês como valor e o nome do mês como rótulo
				const radioButtonsMes = monthRange.map((mes, i) => {
					const checkedClass = "";
					const label = `${mes}`;
					const input = `<input type="radio" name="mes" value="${i + 1}" id="option_b${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
					const radioButton = `<label style="border:none!important;border-radius:10px!important;margin-left:1px" class="efeito-grow btn bg-blue${checkedClass}">${input}${label}</label><br>`;
					return radioButton;
				});

				// Adiciona os botões de opção de rádio atualizados ao elemento HTML com o ID "opcoesMes"
				$('#opcoesMes').html(radioButtonsMes.join(''));
			}

			// Chama a função para criar os botões de opção de rádio para os meses do ano atual
			createMonthRadioButtons(currentYear);

			// Adiciona um ouvinte de eventos ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').on('change', function() {
				// Obtém o ano selecionado
				const selectedYear = parseInt($('input[name=ano]:checked').val());

				// Chama a função para criar os botões de opção de rádio para os meses do ano selecionado
				createMonthRadioButtons(selectedYear);
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
						let conteudoIndicadoresMes = $('#divIndicadoresMes').html();
						
						let conteudoDetalhesPRCI = $('#divDetalhePRCI').html();
						let conteudoDetalhesSLNC = $('#divDetalheSLNC').html();
						let conteudoDivMesAnoCI = $('#divMesAno').html();
						

						// Limpar o conteúdo das divs de detalhes
						$('#divCardDGCIectMes').html('');
						$('#divCardDGCIectAcumulado').html('');
						$('#divIndicadoresMes').html('');
						
						$('#divIndicadorDGCIporOrgaoSubord').html('');
						$('#divIndicadorDGCIporOrgaoResponsavel').html('');
						$('#divIndicadorPRCIporOrgaoSubordinador').html('');
						$('#divIndicadorSLNCporOrgaoSubordinador').html('');
						
						//$('#divIndicadorDetalhesPRCI').html('');
						//$('#divIndicadorDetalhesSLNC').html('');
						$('#divMesAnoCI').html('');
						
						// Adicionar o conteúdo às divs de detalhes das abas
						$('#divIndicadorDGCI_ECT').append(conteudoDGCI_ECT);
						$('#divIndicadorDGCI_ECT').append(conteudoDGCI_ECT_acumulado);
						$('#divIndicadorDGCI_ECT').append(conteudoIndicadoresMes);
						
						//$('#divIndicadorDetalhesPRCI').html(conteudoDetalhesPRCI);
						//$('#divIndicadorDetalhesSLNC').html(conteudoDetalhesSLNC);
						$('#divMesAnoCI').html(conteudoDivMesAnoCI);

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

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabPRCIorgaosSubordinadores_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorPRCIporOrgaoSubordinador').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				}) 

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabSLNCorgaosSubordinadores_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorSLNCporOrgaoSubordinador').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabDGCIorgaosSubordinadores_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDGCIporOrgaoSubord').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabDGCIorgaosResposaveis_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDGCIporOrgaoResponsavel').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabPRCIdetalhe_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDetalhesPRCI').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabSLNCdetalhe_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDetalhesSLNC').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})

				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"tabDGCImes_A_mes_mensal_CI",
						ano:selectedYear,
						mes:selectedMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDGCI_ECT_mes_a_mes').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
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









