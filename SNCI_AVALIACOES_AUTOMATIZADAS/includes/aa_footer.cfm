<cfprocessingdirective pageencoding = "utf-8">
<style>
	.main-footer{
		bottom: 0!important;
		left: 0!important;
		position: fixed!important;
		right: 0!important;
		z-index: 1032!important;
		padding:0.3rem!important;
	}
    
    /* Estilos para o botão de voltar ao topo */
    .scrollTopBtn {
        position: fixed;
        right: 20px;
        bottom: 50px;
        background: none;
        border: none;
        color: #007bff;
        cursor: pointer;
        z-index: 1033; /* Maior que o footer para garantir visibilidade */
        opacity: 0.7;
        transition: all 0.3s ease;
    }
    
    .scrollTopBtn:hover {
        opacity: 1;
        color: #0056b3;
    }
    
    .grow-icon {
        transition: transform 0.2s;
    }
    
    .scrollTopBtn:hover .grow-icon {
        transform: scale(1.2);
    }
</style>
<footer class="main-footer" style="font-size:14px;bottom:-60px;right:-27px; text-align: center;">
	CS/DIGOE/SUGOV/DCINT/GACE - Gerência de Avaliações de Controles Especiais  
	<div class="float-right d-none d-sm-block" style="margin-right:20px">
		SNCI - Avaliações Automatizadas - Versão <b>1.0.0</b>
	</div>
	<button id="scrollTopBtn" class="scrollTopBtn" title="Voltar ao Topo">
		<i class="fas fa-circle-arrow-up fa-3x grow-icon" ></i>
	</button>
</footer>