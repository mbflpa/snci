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

			#iconSync {
				-webkit-animation-name: fa-spin;
						animation-name: fa-spin;
				-webkit-animation-delay: var(--fa-animation-delay, 0s);
						animation-delay: var(--fa-animation-delay, 0s);
				-webkit-animation-direction: var(--fa-animation-direction, normal);
						animation-direction: var(--fa-animation-direction, normal);
				-webkit-animation-duration: var(--fa-animation-duration, 2s);
						animation-duration: var(--fa-animation-duration, 2s);
				-webkit-animation-iteration-count: var(--fa-animation-iteration-count, infinite);
						animation-iteration-count: var(--fa-animation-iteration-count, infinite);
				-webkit-animation-timing-function: var(--fa-animation-timing, linear);
						animation-timing-function: var(--fa-animation-timing, linear);
			}

			@media (prefers-reduced-motion: reduce) {
				.fa-spin {
						-webkit-animation-delay: -1ms;
								animation-delay: -1ms;
						-webkit-animation-duration: 1ms;
								animation-duration: 1ms;
						-webkit-animation-iteration-count: 1;
								animation-iteration-count: 1;
						transition-delay: 0s;
						transition-duration: 0s; 
						}
			}


		</style>

		<div class=" modal fade " id="modalOverlay" >
			<div class="modal-dialog modalOverlay">
				<i id="iconSync" class="fas fa-5x fa-sync-alt" ></i>
			</div>
			
		</div>

		<!-- Preloader -->
		<div class="preloader flex-column justify-content-center align-items-center">
			<img class="animation__shake" src="../SNCI_PROCESSOS/dist/img/correios.png"  width="100" >
			<BR>
			<span style="font-size:30px">SNCI -  Sistema Nacional de Controle Interno</span>
			<span style="font-size:20px">AGUARDE...</span>
		</div>
 		
		<!-- AdminLTE App -->
		<script  type="module" defer src="../SNCI_PROCESSOS/dist/js/adminlte.js"></script>
		<!-- jQuery -->
		<script  type="module" defer src="../SNCI_PROCESSOS/plugins/jquery/jquery.min.js"></script>

		<!-- Bootstrap 4 -->
		<script  type="module" defer src="../SNCI_PROCESSOS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>

		<!-- jQuery UI 1.11.4 -->
		<script  type="module" defer src="../SNCI_PROCESSOS/plugins/jquery-ui/jquery-ui.min.js"></script>
		
    </body>
	
</html>