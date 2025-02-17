<!-- Início do componente do Sidebar -->
<style>
    /* Estilos do Sidebar com efeito vidro fosco */
    #importantSidebar {
        position: fixed;
        top: 60px;
        left: 600px;
        right: 0;
        height: 100%;
        max-height: calc(100vh - 60px); /* nova propriedade para limitar a altura */
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
        // Define estilo inicial do botão como vermelho
        const btn = $("#toggleSidebar");
        btn.css({
            'background': 'linear-gradient(135deg, #ff416c, #ff4b2b)',
            'box-shadow': '0 4px 10px rgba(0,0,0,0.2)'
        });

        // Função que atualiza a aparência do botão baseado no status das FAQs
        function updateButtonAppearance() {
            let readFaqs = JSON.parse(localStorage.getItem('readFaqs') || '[]');
            let totalBadges = $('.read-status-badge').length;
            let readBadges = $('.read-status-badge.read').length;

            // Só muda para verde se houver badges e todas estiverem lidas
            if (totalBadges > 0 && totalBadges === readBadges) {
                btn.css({
                    'background': 'var(--azul_claro_correios)',
                    'box-shadow': 'none',
                    'transform': 'none'
                });
            } else {
                btn.css({
                    'background': 'linear-gradient(135deg, #ff416c, #ff4b2b)',
                    'box-shadow': '0 4px 10px rgba(0,0,0,0.2)'
                });
            }
        }

        // Função que controla todas as animações do botão
        function controlButtonAnimations() {
            let totalBadges = $('.read-status-badge').length;
            let readBadges = $('.read-status-badge.read').length;
            const btn = $("#toggleSidebar");

            updateButtonAppearance(); // Atualiza a aparência primeiro
            updateCircleAnimation(); // Nova chamada para controlar o círculo separadamente

            // Se todas as FAQs estão lidas ou não há FAQs
            if (totalBadges === 0 || totalBadges === readBadges) {
                // Cancela e remove animações
                clearTimeout(window.animationTimeout);
                btn.removeClass('stretching returning btn-5 radiate shake');
                $('.dash-circle, .circle-text').css('animation', 'none');
                btn.off('mouseenter mouseleave');
                return false;
            }
            return true;
        }

        // Verificação inicial ao carregar
        setTimeout(function() {
            updateButtonAppearance();
            const btn = $("#toggleSidebar");
            const animate = async () => {
                if (!controlButtonAnimations()) return; // Retorna se não deve animar
                
                btn.addClass('stretching');
                await new Promise(resolve => setTimeout(resolve, 700));
                btn.addClass('returning').removeClass('stretching');
                await new Promise(resolve => setTimeout(resolve, 0));
                btn.removeClass('returning');
                btn.css('transform', '');
                if (controlButtonAnimations()) { // Verifica novamente antes de adicionar efeitos
                    btn.addClass('btn-5 radiate');
                    window.animationTimeout = setTimeout(() => {
                        btn.removeClass('radiate');
                    }, 5000);
                }
            };
            animate();
        }, 2000);

        // Verificações periódicas
        setInterval(updateButtonAppearance, 500);
        setInterval(controlButtonAnimations, 500);

        // Modifica o click handler para verificar os efeitos
        $("#toggleSidebar").click(function(e){
            e.stopPropagation();
            $("#importantSidebar").toggleClass("open");
            $("#toggleSidebar").css({ left: "auto", right: "0" });
            
            // Pausa a animação apenas quando o sidebar está aberto
            if($("#importantSidebar").hasClass("open")){
                $(".dash-circle, .circle-text").css("animation-play-state", "paused");
            } else {
                // Ao fechar, verifica se deve voltar a girar
                updateCircleAnimation();
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

        // Verifica o status a cada 500ms
        setInterval(controlButtonAnimations, 500);
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

    // Função que controla as animações do círculo
    function updateCircleAnimation() {
        let totalBadges = $('.read-status-badge').length;
        let readBadges = $('.read-status-badge.read').length;
        const hasUnreadFaqs = totalBadges > 0 && totalBadges !== readBadges;

        if (hasUnreadFaqs) {
            // Se existem FAQs não lidas, reinicia as animações
            $('.dash-circle').css('animation', 'spin 2s linear infinite');
            $('.circle-text').css('animation', 'counter-spin 2s linear infinite');
        } else if (totalBadges === 0) {
            // Se não existem FAQs, para as animações
            $('.dash-circle, .circle-text').css('animation', 'none');
        }
        // Se todas as FAQs estão lidas mas existem FAQs, mantém girando
    }
</script>

<script>
$(document).ready(function() {
    checkUnreadFaqs();

    // Função para verificar se existem FAQs não lidas
    function checkUnreadFaqs() {
        let readFaqs = JSON.parse(localStorage.getItem('readFaqs') || '[]');
        let hasUnread = false;
        let totalBadges = $('.read-status-badge').length;
        let readBadges = $('.read-status-badge.read').length;

        // Se todas as badges estão marcadas como lidas
        if (totalBadges > 0 && totalBadges === readBadges) {
            const $toggleButton = $('#toggleSidebar');
            
            // Remove todas as animações e efeitos
            $toggleButton
                .removeClass('stretching returning btn-5 radiate shake')
                .find('.dash-circle, .circle-text')
                .css('animation', 'none');
            
            // Para a animação do círculo
            $('.dash-circle').css('animation', 'none');
            $('.circle-text').css('animation', 'none');
            
            // Remove qualquer estilo inline residual
            $toggleButton.attr('style', '');
            
            // Remove o efeito de brilho/sombra
            $toggleButton.css({
                'box-shadow': 'none',
                'background': 'var(--azul_claro_correios)', // Cor mais neutra quando todas estão lidas
                'transform': 'none'
            });
            
            // Desabilita os eventos de animação
            $toggleButton.off('mouseenter mouseleave');
        }
    }

    // Aumenta a frequência de verificação para 500ms
    setInterval(checkUnreadFaqs, 500);

    // Adiciona verificação após qualquer interação com FAQ
    $(document).on('click', '.collapse', function() {
        setTimeout(checkUnreadFaqs, 100);
    });
});
</script>
<!-- Fim do componente do Sidebar -->
