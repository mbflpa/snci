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
		
		<section  class="content-header">
			<div class="container-fluid">
						
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Indicadores: <strong>Geração de Dados Mensais</strong></h4>
						</div>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid">

				<div style="display: flex;align-items: center;">
					<span style="color:#0083ca;font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>

				<div style="display: flex;align-items: center;">
                    <span style="color:#0083ca;font-size:20px;margin-right:10px">Mês:</span>
                    <div id="opcoesMes" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>

				
				<div id="divTabela" style="width:800px;margin-top:50px;"></div>	
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
				// Obtém o ano selecionado
				const selectedYear = parseInt($('input[name=ano]:checked').val());

				// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente, com base no ano selecionado
				const monthRange = monthNames.slice(0, selectedYear === currentYear ? currentMonth  : 12);

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
				// Chamar a função para obter os dados quando o documento estiver pronto
				obterDados();
			});

			
			 $('#opcoesMes').on('click', 'input[name=mes]', function() {
				// Obtém o ano selecionado		
				let selectedYear = parseInt($('input[name=ano]:checked').val());	
				// Obtém o mês selecionado
				let selectedMonth = parseInt($(this).val());
		
						$('#modalOverlay').modal('show')
						setTimeout(function() {	
							
							$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
								type: "post",
								url: "cfc/pc_cfcIndicadores.cfc",
								data:{
									method:"verificaExisteDadosGerados",
									ano:selectedYear,
									mes:selectedMonth
								},
								async: false,
								success: function(result) {	
									gerarDados(result)
									$('#opcoesMes').find('label').removeClass('active');
								},
								error: function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										$('#opcoesMes').find('label').removeClass('active');
									});							
									$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
									$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL		
								}
							})
							

						}, 1000);

			});

			function gerarDados(existeDados){
				let ano = parseInt($('input[name=ano]:checked').val());
				let mes = parseInt($('input[name=mes]:checked').val());
				//se existeDados for true, pergunta se deseja gerar novamente, caso contrário, gera os dados
				if(existeDados > 0){
					var mensagem = 'Já existem dados gerados para <strong style="color:#2581c8">' + monthNames[mes - 1] + '/' + ano + '</strong>. Deseja gerar novamente?<br><br><span style="color:red"><strong>Atenção:</strong> Ao clicar em "Sim", os dados gerados anteriormente serão substituídos.</span>';
					Swal.fire({
						title: mensagem,
						showDenyButton: true,
						confirmButtonText: `Sim`,
						denyButtonText: `Não`,
					}).then((result) => {
						/* Read more about isConfirmed, isDenied below */
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							setTimeout(function() {	
								$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
									type: "post",
									url: "cfc/pc_cfcIndicadores.cfc",
									data:{
										method:"gerarDadosParaIndicadores",
										ano:ano,
										mes:mes
									},
									async: false,
									success: function(result) {	
										var xmlDoc = $.parseXML(result);
										var $xml = $(xmlDoc);
										var quantDados = $xml.find("number").text();
										
																				
										// Chamar a função para obter os dados quando o documento estiver pronto
										obterDados();
										$('#modalOverlay').delay(500).hide(0, function() {
											$('#modalOverlay').modal('hide');
											if(quantDados== 0){
												Swal.fire('Não foram encontrados dados para o ano e mês solicitados!', '', 'info')
											}else{
												Swal.fire('Dados gerados com sucesso!', '', 'success')
											}
											$(".content-wrapper").css("height", "auto");
										});

									},
									error: function(xhr, ajaxOptions, thrownError) {
										$('#modalOverlay').delay(500).hide(0, function() {
											$('#modalOverlay').modal('hide');
											
										});
										$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
										$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
										$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
											
									}
								})
							}, 1000);
						} else if (result.isDenied) {
							
								$('#modalOverlay').modal('hide');
								Swal.fire('Operação cancelada', '', 'info')
								$('#opcoesMes').find('label').removeClass('active');
								
							
						}
					})
				}else{
					var mensagem = 'Deseja gerar os dados para ' + monthNames[mes - 1] + '/' + ano + '?';
					Swal.fire({
						title: mensagem,
						showDenyButton: true,
						confirmButtonText: `Sim`,
						denyButtonText: `Não`,
					}).then((result) => {
						/* Read more about isConfirmed, isDenied below */
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							setTimeout(function() {	
								$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
									type: "post",
									url: "cfc/pc_cfcIndicadores.cfc",
									data:{
										method:"gerarDadosParaIndicadores",
										ano:parseInt($('input[name=ano]:checked').val()),
										mes:parseInt($('input[name=mes]:checked').val())
									},
									async: false,
									success: function(result) {	
										var xmlDoc = $.parseXML(result);
										var $xml = $(xmlDoc);
										var quantDados = $xml.find("number").text();
										
										// Chamar a função para obter os dados quando o documento estiver pronto
										obterDados();
										$('#modalOverlay').modal('hide');
										if(quantDados == 0){
												Swal.fire('Não foram encontrados dados para <strong>' + monthNames[mes - 1] + '/' + ano + '</strong> que possam ser utilizados nos cálculos dos indicadores!', '', 'info')
										}else{
											Swal.fire('Dados gerados com sucesso!', '', 'success')
										}
										$(".content-wrapper").css("height", "auto");	
												

									},
									error: function(xhr, ajaxOptions, thrownError) {
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											$('#opcoesMes').find('label').removeClass('active');
										});
										$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
										$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
										$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
											
									}
								})
							}, 1000);
						} else if (result.isDenied) {
							
							$('#modalOverlay').modal('hide');
							Swal.fire('Operação cancelada', '', 'info')
								
						}
					})
				}

			}

			// Chamar a função para obter os dados quando o documento estiver pronto
			obterDados();
			
		}); 
	
		// Função para obter os dados do ColdFusion e preencher a tabela DataTable
		function obterDados() {
			var ano = parseInt($('input[name=ano]:checked').val());
            $('#modalOverlay').modal('show')
			setTimeout(function() {	
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"mesesDadosGerados",
						ano:ano
					},
					async: false,
					success: function(response) {
						$('#divTabela').html(response);
						$('#modalOverlay').delay(500).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
						
					},
					error: function(xhr, ajaxOptions, thrownError) {
	
						$('#modalOverlay').delay(500).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				});
				
			}, 500);
		}

		
		



		
    </script>


</body>
</html>









