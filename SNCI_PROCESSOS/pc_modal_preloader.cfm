<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
  		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<!-- Theme style -->
		<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/adminlte.css">
	    <link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/stylesSNCI.css">
		<!-- Font Awesome -->
		<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/all.min.css">
		<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/fontawesome.min.css">
			
		
		
    </head>
    <body>
        <div class="modal fade" id="modal-danger">
			<div class="modal-dialog">
				<div class="modal-content bg-danger">
				<div class="modal-header">
					<h4 class="modal-title">Danger Modal</h4>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class="modal-body">
					<p>One fine body&hellip;</p>
				</div>
				<div class="modal-footer justify-content-between">
					<button type="button" class="btn btn-outline-light" data-dismiss="modal">Fechar</button>
				</div>
				</div>
				<!-- /.modal-content -->
			</div>
			<!-- /.modal-dialog -->
		</div>
		<!-- /.modal -->
		
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
				background-color:#00416B!important;
				
			}
			#contentConfirm.modal-content{
				opacity:0.8;
				background-color:#00416B!important;
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
				mix-blend-mode: darken;
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

<div class="modal fade" id="modalOverlay">
    <div class="modal-dialog modalOverlay">
        <div class="loader" >
            <img src="../SNCI_PROCESSOS/dist/img/correios.png"  alt="logo Correios">
            <span class="texto-aguarde" >AGUARDE...</span>
        </div>
    </div>
</div>

		<!-- Preloader -->
		<div class="preloader flex-column justify-content-center align-items-center">
			<img class="animation__shake" src="../SNCI_PROCESSOS/dist/img/correios.png"  width="100" >
			<BR>
			<span style="font-size:30px">SNCI -  Sistema Nacional de Controle Interno</span>
			<span style="font-size:20px">AGUARDE...</span>
		</div>
 		
		
    </body>
	
</html>