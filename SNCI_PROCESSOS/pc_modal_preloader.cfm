<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
  		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<!-- Theme style -->
		<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/adminlte.min.css">
	

		<!-- jQuery -->
		<script src="../SNCI_PROCESSOS/plugins/jquery/jquery.min.js"></script>
		
		<style>
			.modalOverlay{
				height:100%;
				display: flex!important;
				justify-content: center;
				align-items: center;
				overflow:hidden;
			}

			#bodyConfirm.modal-body{
				font-size:16px!important;
				color:#fff!important;
				background-color:var(--azul_correios)!important
				
			}
			#contentConfirm.modal-content{
				opacity:0.8;
				background-color:var(--azul_correios)!important
				color:#fff!important;
			}

		

			/* HTML: <div class="loader"></div> */
			.loader {
				width: 150px;
				height: 150px;
				position: relative;
				display: flex;
				flex-direction: column; /* Coloca o texto embaixo da imagem */
				justify-content: center;
				align-items: center;
			}


			.loader::before,
			.loader::after {
				content: "";
				position: absolute;
				width: 100%;
				height: 100%;
				border: 15px solid #fff;
				border-radius: 50%;
				border-color: #2581c8 #fbc32f #fff #fff;
				mix-blend-mode:  multiply;
				animation: l14 1s infinite linear;
			}

			.loader::after {
				animation-direction: reverse;
			}

			@keyframes l14 {
				100% {
					transform: rotate(1turn);
				}
			}

			.loader img {
				position: relative;
				width: 75px;
				height: auto;
				z-index: 2;
				animation: none; /* Desabilita a animação na imagem */
			}

			.texto-aguarde {
				font-size:1rem;
				font-weight: bold; /* Deixa o texto mais grosso */
				color: #fff; /* Define a cor do texto */
				text-shadow: 
					-1px -1px 0 #2581c8,  
					1px -1px 0 #2581c8,
					-1px 1px 0 #2581c8,
					1px 1px 0 #2581c8; /* Adiciona contorno preto ao texto */
			}
		</style>
	
		
		
    </head>
    <body>
        <!-- Preloader -->
		<div class="preloader flex-column justify-content-center align-items-center">
			<img class="animation__shake" src="../SNCI_PROCESSOS/dist/img/correios.png"  width="100" >
			<BR>
			<span style="font-size:30px">SNCI -  Sistema Nacional de Controle Interno</span>
			<span style="font-size:20px">AGUARDE...</span>
		</div>
		
		
		<div class="modal fade" id="modalOverlay">
			<div class="modal-dialog modalOverlay">
				<div class="loader" >
					<img src="../SNCI_PROCESSOS/dist/img/correios.png"  alt="logo Correios">
					<span class="texto-aguarde" >AGUARDE...</span>
				</div>
			</div>
		</div>

		
 		
		
    </body>
	
</html>