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
						
				<div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Consultar Indicadores</h4>
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
			// Obtém o ano atual
			const currentYear = new Date().getFullYear();

			// Cria um array de anos, começando em 2023 e indo até o ano atual, em ordem crescente
			const yearRange = Array(currentYear - 2022).fill().map((_, i) => currentYear - i);

			// Mapeia cada ano para um botão de opção de rádio com o ano como rótulo e valor
			const radioButtonsAno = yearRange.map((year, i) => {
				// Define a classe "active" para o botão de opção de rádio do ano atual
				const checkedClass = year === currentYear ? " active" : "";
				const label = `${year}`;
				const input = `<input type="radio" name="ano" value="${year}" id="option_a${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
				const radioButton = `<label style="border:none!important;border-radius:0!important;" class="btn bg-olive${checkedClass}">${input}${label}</label><br>`;
				return radioButton;
			}).reverse(); // Inverte a ordem dos botões de opção de rádio para que o ano mais recente apareça por último

			// Adiciona os botões de opção de rádio ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').html(radioButtonsAno.join(''));

			// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente
			const monthNames = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];
			const currentMonth = new Date().getMonth();
			const monthRange = monthNames.slice(0, currentYear === parseInt($('input[name=ano]:checked').val()) ? currentMonth + 1 : 12);

			// Mapeia cada mês para um botão de opção de rádio com o número do mês como valor e o nome do mês como rótulo
			const radioButtonsMes = monthRange.map((month, i) => {
				const checkedClass = "";
				const label = `${month}`;
				const input = `<input type="radio" name="mes" value="${i + 1}" id="option_b${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
				const radioButton = `<label style="border:none!important;border-radius:0!important;" class="btn bg-olive${checkedClass}">${input}${label}</label><br>`;
				return radioButton;
			});

			// Adiciona os botões de opção de rádio ao elemento HTML com o ID "opcoesMes"
			$('#opcoesMes').html(radioButtonsMes.join(''));

			// Adiciona um ouvinte de eventos ao elemento HTML com o ID "opcoesAno"
			$('#opcoesAno').on('change', function() {
				// Obtém o ano selecionado
				const selectedYear = parseInt($('input[name=ano]:checked').val());

				// Cria um array de nomes de meses, começando em janeiro e indo até o mês atual, em ordem crescente, com base no ano selecionado
				const monthRange = monthNames.slice(0, selectedYear === currentYear ? currentMonth + 1 : 12);

				// Mapeia cada mês para um botão de opção de rádio com o número do mês como valor e o nome do mês como rótulo
				const radioButtonsMes = monthRange.map((month, i) => {
					const checkedClass = "";
					const label = `${month}`;
					const input = `<input type="radio" name="mes" value="${i + 1}" id="option_b${i}" autocomplete="off"${checkedClass ? ' checked=""' : ""}>`;
					const radioButton = `<label style="border:none!important;border-radius:0!important;" class="btn bg-olive${checkedClass}">${input}${label}</label><br>`;
					return radioButton;
				});

				// Adiciona os botões de opção de rádio atualizados ao elemento HTML com o ID "opcoesMes"
				$('#opcoesMes').html(radioButtonsMes.join(''));
			});



			$('#opcoesMes').on('change', function() {
				// Obtém o ano selecionado		
				const selectedYear = parseInt($('input[name=ano]:checked').val());	
				// Obtém o mês selecionado
				const selectedMonth = parseInt($('input[name=mes]:checked').val());
				
				alert(selectedYear + '-' + selectedMonth);

			});


			

            
        }); 
    </script>


</body>
</html>









