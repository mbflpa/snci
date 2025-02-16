<!-- Início do componente do Sidebar -->
<style>
    /* Estilos do Sidebar com efeito vidro fosco */
    #importantSidebar {
        position: fixed;
        top: 60px;
        left: 600px;
        right: 0;
        height: 100%;
        background: rgba(255, 255, 255, 0.5); /* fundo translúcido */
        backdrop-filter: blur(10px); /* efeito de vidro fosco */
        border-left: 2px solid #ddd;
        box-shadow: -2px 0 5px rgba(0,0,0,0.1);
        padding: 15px;
        overflow-y: auto;
        transform: translateX(100%);
        transition: transform 0.6s ease;
        z-index: 998;
    }
    #importantSidebar.open {
        transform: translateX(0);
    }
    /* Estilos do botão de toggle aprimorados com ajustes para posicionamento à direita */
    #toggleSidebar {
        position: fixed;
        top: 70px;
        right: 0;
        background: linear-gradient(135deg, #ff416c, #ff4b2b);
        color: #fff;
        border: none;
        padding: 5px 20px;
        border-radius: 25px 0 0 25px; /* bordas arredondadas apenas à esquerda */
        cursor: pointer;
        z-index: 999;
        display: flex;
        align-items: center;
        transition: transform 0.3s ease, box-shadow 0.3s ease, background 0.3s ease;
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }
    #toggleSidebar:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 15px rgba(0, 0, 0, 0.3);
        background: linear-gradient(135deg, #ff4b2b, #ff416c);
    }
    .icon-container {
        position: relative;
        display: inline-block;
        margin-right: 5px;
        margin-left: -12px;
    }
    .dash-circle {
        display: inline-block;
        width: 30px;
        height: 30px;
        border: 2px dashed #fff;
        border-radius: 50%;
        animation: spin 2s linear infinite;
        position: relative;
        margin-top: 3px;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    .circle-text {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 18px;
        font-weight: bold;
        color: #fff;
        animation: counter-spin 2s linear infinite;
    }
    @keyframes counter-spin {
        from { transform: translate(-50%, -50%) rotate(0deg); }
        to { transform: translate(-50%, -50%) rotate(-360deg); }
    }

    /* Substituir a animação antiga por classes de estado */
    #toggleSidebar.stretching {
        width: 50vw; /* 50% da largura da viewport */
        box-shadow: 0 0 10px 5px rgba(255, 0, 0, 0.2);
        transform: scale(1.05);
    }

    #toggleSidebar.returning {
        width: auto;
        transform: scale(1);
    }

    /* Adiciona o efeito .btn-5 ao botão quando retornar à posição normal */
    .btn-5 {
        border: 0 solid;
        box-shadow: inset 0 0 20px rgba(255, 255, 255, 0);
        outline: 1px solid;
        outline-color: rgba(255, 255, 255, 0.5);
        outline-offset: 0px;
        text-shadow: none;
        transition: all 1250ms cubic-bezier(0.19, 1, 0.22, 1);
    }
    .btn-5:hover {
        border: 1px solid;
        box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.5), 0 0 20px rgba(255, 255, 255, 0.2);
        outline-color: rgba(255, 255, 255, 0);
        outline-offset: 15px;
        text-shadow: 1px 1px 2px #427388; 
    }

    /* Efeito de sacudida tipo borracha */
    @keyframes shake {
        0% { transform: translateY(0); }
        20% { transform: translateY(-10px); }
        40% { transform: translateY(10px); }
        60% { transform: translateY(-10px); }
        80% { transform: translateY(10px); }
        100% { transform: translateY(0); }
    }
    #toggleSidebar.shake {
        animation: shake 0.5s;
    }

    

    /* Efeito radiação pulsante moderno */
    @keyframes radiate {
        0% { box-shadow: 0 0 0 0 rgba(255,0,0,0.85); }
        50% { box-shadow: 0 0 25px 15px rgba(255,0,0,0.25); }
        100% { box-shadow: 0 0 0 0 rgba(255,0,0,0.85); }
    }
    #toggleSidebar.radiate {
        animation: radiate 1s infinite;
    }
</style>

<!-- HTML do Sidebar e Botão -->
<div id="importantSidebar">
    <!-- Conteúdo dinâmico ou estático -->
    <div id="formFaqDiv"></div>
</div>
<button id="toggleSidebar">
    <span class="icon-container">
        <span class="dash-circle">
            <span class="circle-text">?</span>
        </span>
    </span>
    Informações Importantes
</button>

<!-- jQuery para controlar o comportamento do Sidebar -->
<script>
    $(document).ready(function(){
        // Inicia a animação do estilingue 2000ms após a carga da página
        setTimeout(function() {
            const btn = $("#toggleSidebar");
            const animate = async () => {
                btn.addClass('stretching');
                await new Promise(resolve => setTimeout(resolve, 700)); // tempo de esticada
                btn.addClass('returning').removeClass('stretching');
                // Removemos o delay para iniciar imediatamente o efeito de pêndulo
                await new Promise(resolve => setTimeout(resolve, 0));
                btn.removeClass('returning');
                btn.css('transform', '');
                btn.addClass('btn-5'); // Aplica o efeito .btn-5 ao retornar
                btn.addClass('radiate'); // Aplica efeito radiação moderno
                await new Promise(resolve => setTimeout(resolve, 5000)); // Dura 5s
                btn.removeClass('radiate');
            };
            animate();
        }, 2000); // alterado para 2000ms

        $("#toggleSidebar").click(function(e){
            e.stopPropagation();
            $("#importantSidebar").toggleClass("open");
            $("#toggleSidebar").css({ left: "auto", right: "0" });
            // Pausar ou reiniciar a animação de .dash-circle e .circle-text
            if($("#importantSidebar").hasClass("open")){
                $(".dash-circle, .dash-circle .circle-text").css("animation-play-state", "paused");
            } else {
                $(".dash-circle, .dash-circle .circle-text").css("animation-play-state", "running");
            }
        });
        $(document).on("mousemove", function(e){
            if($("#importantSidebar").hasClass("open") &&
               $(e.target).closest("#importantSidebar, #toggleSidebar").length === 0){
                   $("#importantSidebar").removeClass("open");
                   $("#toggleSidebar").css({ left: "auto", right: "0" });
                   // Reinicia a animação quando o sidebar fechar
                   $(".dash-circle, .dash-circle .circle-text").css("animation-play-state", "running");
            }
        });
    });
    
    // Adiciona função mostraFormFaq() para carregar os FAQs
    function mostraFormFaq(){
        $.ajax({
            type: "post",
            url: "cfc/pc_cfcFaqs.cfc",
            data: { method: "formFaqIndex" },
            dataType: "text"  // Lida com JSON ou HTML
        })
        .done(function(response) {
            if(!response || response.trim() === ""){
                $('#formFaqDiv').html("<p>Nenhum FAQ retornado pelo servidor.</p>");
                $("#toggleSidebar").hide();
                return;
            }
            var result;
            try {
                result = JSON.parse(response);
            } catch(e) {
                result = { type: "text", content: response };
            }
            $('#formFaqDiv').html(result.content);
            var faqCount = $('#formFaqDiv .card-title').length;
            if (faqCount > 0) {
                $("#toggleSidebar").show();
                $("#toggleSidebar").contents().filter(function(){ return this.nodeType === 3; }).remove();
                if(faqCount === 1){
                    $("#toggleSidebar").append(" Informação Importante");
                } else {
                    $("#toggleSidebar").append(" Informações Importantes");
                }
            } else {
                $("#toggleSidebar").hide();
            }
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
<!-- Fim do componente do Sidebar -->
